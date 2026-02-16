"""
语音转文字服务 (STT Service)
支持火山引擎大模型录音文件极速识别
API文档：https://www.volcengine.com/docs/6561/1631584
"""

import asyncio
import base64
import json
import logging
import os
import subprocess
import tempfile
import uuid
from enum import Enum
from pathlib import Path
from typing import Optional, Dict, List, Any

import httpx

from config import settings

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class STTErrorCode(Enum):
    """STT错误码"""
    SUCCESS = "20000000"
    SILENCE_AUDIO = "20000003"
    INVALID_PARAMS = "45000001"
    EMPTY_AUDIO = "45000002"
    INVALID_FORMAT = "45000151"
    SERVER_ERROR = "55000031"
    UNKNOWN = "UNKNOWN"


class STTException(Exception):
    """STT服务异常"""
    def __init__(self, message: str, code: str = "", log_id: str = ""):
        self.message = message
        self.code = code
        self.log_id = log_id
        super().__init__(f"[{code}] {message} (log_id: {log_id})")


class STTService:
    """STT服务基类"""
    async def transcribe(self, audio_path: str) -> str:
        """转写音频文件为文字"""
        raise NotImplementedError

    async def transcribe_with_details(self, audio_path: str) -> Dict[str, Any]:
        """转写音频文件，返回详细信息"""
        text = await self.transcribe(audio_path)
        return {"text": text}


class MockSTTService(STTService):
    """模拟STT服务（用于测试）"""
    async def transcribe(self, audio_path: str) -> str:
        # 模拟处理时间
        await asyncio.sleep(2)
        return "这是一个测试的语音转写内容。今天天气真不错，我想去公园走走。"


class VolcengineSTTService(STTService):
    """火山引擎STT服务实现

    支持两种模式：
    1. 标准版（默认）：提交任务 + 查询结果
       - API文档：https://www.volcengine.com/docs/6561/1354868
       - 资源ID：volc.bigasr.auc (模型1.0) 或 volc.seedasr.auc (模型2.0)
       - 需要音频公网可访问的URL
    2. 极速版：一次请求返回结果
       - API文档：https://www.volcengine.com/docs/6561/1631584
       - 资源ID：volc.bigasr.auc_turbo
       - 支持base64上传

    特点：
    - 音频时长不超过5小时，大小不超过100MB
    - 支持格式：WAV, MP3, OGG, OPUS, M4A (AAC)
    - 自动轮询查询结果
    """

    # API配置 - 标准版
    SUBMIT_API_URL = "https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit"
    QUERY_API_URL = "https://openspeech.bytedance.com/api/v3/auc/bigmodel/query"

    # 资源ID选项
    RESOURCE_ID_V1 = "volc.bigasr.auc"      # 豆包录音文件识别模型1.0
    RESOURCE_ID_V2 = "volc.seedasr.auc"     # 豆包录音文件识别模型2.0
    RESOURCE_ID_TURBO = "volc.bigasr.auc_turbo"  # 极速版（需要特殊权限）

    API_SEQUENCE = "-1"

    # 请求配置
    MAX_RETRIES = 3
    RETRY_DELAY = 1.0  # 秒
    TIMEOUT = 30.0  # 秒
    QUERY_INTERVAL = 1.0  # 查询间隔（秒）
    MAX_QUERY_TIME = 120.0  # 最大查询时间（秒）

    # 支持的音频格式
    SUPPORTED_FORMATS = {'.wav', '.mp3', '.ogg', '.opus', '.m4a'}

    def __init__(
        self,
        app_id: str,
        access_key: str,
        secret_key: Optional[str] = None,
        timeout: float = TIMEOUT,
        max_retries: int = MAX_RETRIES,
        resource_id: Optional[str] = None,
        base_url: Optional[str] = None,
        language: str = "zh"  # 默认中文
    ):
        """
        初始化火山引擎STT服务

        Args:
            app_id: 火山引擎控制台获取的APP ID
            access_key: 火山引擎控制台获取的Access Key
            secret_key: 密钥（预留，当前API不需要）
            timeout: 请求超时时间（秒）
            max_retries: 最大重试次数
            resource_id: 资源ID（默认使用模型2.0）
            base_url: 音频文件的公网访问URL前缀（用于生成可访问的音频URL）
            language: 识别语言，默认"zh"（中文），可选"en"（英文）、"yue"（粤语）
        """
        self.app_id = app_id
        self.access_key = access_key
        self.secret_key = secret_key
        self.timeout = timeout
        self.max_retries = max_retries
        self.resource_id = resource_id or self.RESOURCE_ID_V2
        self.base_url = base_url
        self.language = language

        logger.info(f"初始化火山引擎STT服务: app_id={app_id}, resource_id={self.resource_id}, language={language}")

    def __del__(self):
        """清理资源"""
        pass

    def _validate_audio_file(self, audio_path: str) -> Path:
        """
        验证音频文件

        Args:
            audio_path: 音频文件路径

        Returns:
            Path对象

        Raises:
            FileNotFoundError: 文件不存在
            ValueError: 文件格式不支持
        """
        path = Path(audio_path)

        if not path.exists():
            raise FileNotFoundError(f"音频文件不存在: {audio_path}")

        if not path.is_file():
            raise ValueError(f"路径不是文件: {audio_path}")

        suffix = path.suffix.lower()
        if suffix not in self.SUPPORTED_FORMATS:
            raise ValueError(
                f"不支持的音频格式: {suffix}. "
                f"支持的格式: {', '.join(self.SUPPORTED_FORMATS)}"
            )

        return path

    def _get_audio_url(self, audio_path: str) -> str:
        """
        获取音频文件的公网访问URL

        Args:
            audio_path: 音频文件路径

        Returns:
            音频文件的URL

        Raises:
            ValueError: 无法生成公网URL
        """
        # 如果已配置base_url，直接构造完整URL
        if self.base_url:
            filename = Path(audio_path).name
            return f"{self.base_url.rstrip('/')}/{filename}"

        # 尝试从环境变量获取服务器地址
        # 这里假设音频文件在 uploads/ 目录下，可以通过 /uploads/{filename} 访问
        filename = Path(audio_path).name

        # TODO: 需要配置实际的服务器公网地址或域名
        raise ValueError(
            "无法生成音频公网URL。请配置 base_url 参数或在环境变量中设置 SERVER_URL。"
        )

    async def _submit_task(self, audio_url: str) -> str:
        """
        提交识别任务

        Args:
            audio_url: 音频文件的公网URL

        Returns:
            任务ID

        Raises:
            STTException: 提交任务失败
        """
        task_id = str(uuid.uuid4())

        headers = {
            "X-Api-App-Key": self.app_id,
            "X-Api-Access-Key": self.access_key,
            "X-Api-Resource-Id": self.resource_id,
            "X-Api-Request-Id": task_id,
            "X-Api-Sequence": self.API_SEQUENCE,
        }

        # 获取音频格式
        audio_format = Path(audio_url).suffix.lstrip('.')
        if audio_format not in [f.lstrip('.') for f in self.SUPPORTED_FORMATS]:
            raise ValueError(f"不支持的音频格式: {audio_format}")

        body = {
            "user": {
                "uid": self.app_id
            },
            "audio": {
                "format": audio_format,
                "url": audio_url
            },
            "request": {
                "model_name": "bigmodel",
                "language": self.language,  # 使用配置的语言
                "enable_itn": True,  # 启用逆文本标准化
                "enable_punc": True,  # 启用标点符号
            }
        }

        logger.info(f"提交STT任务，音频URL: {audio_url}")

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    self.SUBMIT_API_URL,
                    headers=headers,
                    json=body
                )

                status_code = response.headers.get("X-Api-Status-Code", "")
                message = response.headers.get("X-Api-Message", "")
                log_id = response.headers.get("X-Tt-Logid", "")

                logger.info(f"提交任务响应 - 状态码: {status_code}, 消息: {message}, log_id: {log_id}")

                if status_code == "20000000":
                    # 成功
                    logger.info(f"任务提交成功，任务ID: {task_id}")
                    return task_id
                else:
                    raise STTException(f"提交任务失败: {message}", code=status_code, log_id=log_id)

        except (httpx.TimeoutException, httpx.NetworkError) as e:
            raise STTException(f"网络请求失败: {e}")

    async def _query_result(self, task_id: str) -> Optional[Dict[str, Any]]:
        """
        查询识别结果

        Args:
            task_id: 任务ID

        Returns:
            识别结果字典，如果任务未完成返回None

        Raises:
            STTException: 查询失败
        """
        headers = {
            "X-Api-App-Key": self.app_id,
            "X-Api-Access-Key": self.access_key,
            "X-Api-Resource-Id": self.resource_id,
            "X-Api-Request-Id": task_id,  # 使用任务ID作为Request-Id
        }

        body = {}  # 查询请求体为空

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    self.QUERY_API_URL,
                    headers=headers,
                    json=body
                )

                status_code = response.headers.get("X-Api-Status-Code", "")
                message = response.headers.get("X-Api-Message", "")
                log_id = response.headers.get("X-Tt-Logid", "")

                if status_code == "20000000":
                    # 识别完成
                    data = response.json()
                    logger.info(f"识别完成，log_id: {log_id}")
                    return data
                elif status_code in ["20000001", "20000002"]:
                    # 处理中/队列中
                    logger.debug(f"任务处理中: {message}")
                    return None
                else:
                    raise STTException(f"查询失败: {message}", code=status_code, log_id=log_id)

        except (httpx.TimeoutException, httpx.NetworkError) as e:
            raise STTException(f"网络请求失败: {e}")

    async def _transcribe_with_retry(self, audio_path: str) -> Dict[str, Any]:
        """
        带重试机制的转写（标准版：submit + query）

        Args:
            audio_path: 音频文件路径

        Returns:
            API返回的结果字典

        Raises:
            STTException: 重试失败后抛出异常
        """
        last_exception = None

        for attempt in range(self.max_retries):
            try:
                # 验证音频文件
                self._validate_audio_file(audio_path)

                # 获取音频URL
                audio_url = self._get_audio_url(audio_path)
                logger.info(f"音频URL: {audio_url}")

                # 提交任务
                task_id = await self._submit_task(audio_url)

                # 轮询查询结果
                start_time = asyncio.get_event_loop().time()
                result = None

                while (asyncio.get_event_loop().time() - start_time) < self.MAX_QUERY_TIME:
                    result = await self._query_result(task_id)

                    if result is not None:
                        # 识别完成
                        return result

                    # 等待后重试
                    logger.debug(f"等待 {self.QUERY_INTERVAL} 秒后重试查询...")
                    await asyncio.sleep(self.QUERY_INTERVAL)

                # 超时
                raise STTException("识别超时，请稍后重试", code="TIMEOUT")

            except STTException as e:
                if e.code == "RETRY_FAILED":
                    last_exception = e
                    # 如果还有重试机会，等待后重试
                    if attempt < self.max_retries - 1:
                        await asyncio.sleep(self.RETRY_DELAY * (attempt + 1))
                else:
                    # STT业务异常不重试，直接抛出
                    raise e

            except Exception as e:
                last_exception = e
                logger.error(f"未知错误 (尝试 {attempt + 1}/{self.max_retries}): {e}")

                # 如果还有重试机会，等待后重试
                if attempt < self.max_retries - 1:
                    await asyncio.sleep(self.RETRY_DELAY * (attempt + 1))

        # 所有重试都失败
        raise STTException(
            f"STT请求失败，已重试{self.max_retries}次: {str(last_exception)}",
            code="RETRY_FAILED"
        )

    def _extract_text_from_result(self, result: Dict[str, Any]) -> str:
        """
        从API结果中提取文本

        Args:
            result: API返回的结果字典

        Returns:
            识别的文本
        """
        try:
            # 获取result字段
            result_data = result.get("result", {})
            text = result_data.get("text", "")

            if not text:
                logger.warning("API返回的文本为空")

            return text
        except Exception as e:
            logger.error(f"提取文本失败: {e}")
            return ""

    async def transcribe(self, audio_path: str) -> str:
        """
        带重试机制的转写

        Args:
            audio_path: 音频文件路径

        Returns:
            API返回的结果字典

        Raises:
            STTException: 重试失败后抛出异常
        """
        last_exception = None

        for attempt in range(self.max_retries):
            try:
                # 验证音频文件
                path = self._validate_audio_file(audio_path)

                # 编码音频为base64
                logger.info(f"编码音频文件: {audio_path}")
                audio_base64 = self._encode_audio_to_base64(path)
                logger.info(f"音频大小: {len(audio_base64)} 字符 (base64编码后)")

                # 构建请求
                headers = self._build_request_headers()
                body = self._build_request_body(audio_base64)

                logger.info(f"发送STT请求 (尝试 {attempt + 1}/{self.max_retries})")

                # 发送请求
                async with httpx.AsyncClient(timeout=self.timeout) as client:
                    response = await client.post(
                        self.API_URL,
                        headers=headers,
                        json=body
                    )

                    # 解析响应
                    result = self._parse_response(response)
                    return result

            except (httpx.TimeoutException, httpx.NetworkError) as e:
                last_exception = e
                logger.warning(f"网络错误 (尝试 {attempt + 1}/{self.max_retries}): {e}")

                # 如果还有重试机会，等待后重试
                if attempt < self.max_retries - 1:
                    await asyncio.sleep(self.RETRY_DELAY * (attempt + 1))

            except STTException as e:
                # STT业务异常不重试，直接抛出
                raise e

            except Exception as e:
                last_exception = e
                logger.error(f"未知错误 (尝试 {attempt + 1}/{self.max_retries}): {e}")

                # 如果还有重试机会，等待后重试
                if attempt < self.max_retries - 1:
                    await asyncio.sleep(self.RETRY_DELAY * (attempt + 1))

        # 所有重试都失败
        raise STTException(
            f"STT请求失败，已重试{self.max_retries}次: {str(last_exception)}",
            code="RETRY_FAILED"
        )

    async def transcribe(self, audio_path: str) -> str:
        """
        使用火山引擎API转写音频

        Args:
            audio_path: 音频文件路径

        Returns:
            转写后的文本内容

        Raises:
            FileNotFoundError: 音频文件不存在
            ValueError: 音频格式不支持
            STTException: STT API调用失败
        """
        # 检查配置
        if not all([self.app_id, self.access_key]):
            logger.warning("火山引擎API未配置，返回模拟数据")
            await asyncio.sleep(1)
            return "火山引擎API未配置，返回模拟数据。"

        try:
            logger.info(f"开始转写音频: {audio_path}")

            # 调用API（带重试）
            result = await self._transcribe_with_retry(audio_path)

            # 提取文本
            text = self._extract_text_from_result(result)

            logger.info(f"转写完成，文本长度: {len(text)}")
            return text

        except STTException as e:
            logger.error(f"STT转写失败: {e}")
            return f"错误：{e.message}"
        except FileNotFoundError as e:
            logger.error(f"文件不存在: {e}")
            return f"错误：找不到音频文件"
        except ValueError as e:
            logger.error(f"参数错误: {e}")
            return f"错误：{str(e)}"
        except Exception as e:
            logger.error(f"未知错误: {e}")
            return f"错误：语音识别失败 - {str(e)}"

    async def transcribe_with_details(self, audio_path: str) -> Dict[str, Any]:
        """
        转写音频文件，返回详细信息

        Args:
            audio_path: 音频文件路径

        Returns:
            包含详细信息的字典：
            - text: 识别的文本
            - duration: 音频时长（毫秒）
            - utterances: 详细的句子片段
        """
        # 检查配置
        if not all([self.app_id, self.access_key]):
            logger.warning("火山引擎API未配置，返回模拟数据")
            await asyncio.sleep(1)
            return {
                "text": "火山引擎API未配置，返回模拟数据。",
                "duration": 0,
                "utterances": []
            }

        try:
            # 调用API
            result = await self._transcribe_with_retry(audio_path)

            # 提取详细信息
            audio_info = result.get("audio_info", {})
            duration = audio_info.get("duration", 0)

            result_data = result.get("result", {})
            text = result_data.get("text", "")
            utterances = result_data.get("utterances", [])

            return {
                "text": text,
                "duration": duration,
                "utterances": utterances
            }

        except Exception as e:
            logger.error(f"获取详细信息失败: {e}")
            return {
                "text": f"错误：{str(e)}",
                "duration": 0,
                "utterances": []
            }

def get_stt_service():
    """
    工厂函数：返回配置的STT服务

    检查环境变量或配置文件中的STT服务配置，
    返回相应的STT服务实例。

    Returns:
        STTService实例
    """
    logger.info("=" * 60)
    logger.info("初始化STT服务")
    logger.info("=" * 60)

    # 检查是否配置了火山引擎密钥
    logger.info("检查STT配置:")
    logger.info(f"  - STT_ACCESS_KEY: {'✅ 已配置' if settings.STT_ACCESS_KEY else '❌ 未配置'}")
    logger.info(f"  - STT_SECRET_KEY: {'✅ 已配置' if settings.STT_SECRET_KEY else '❌ 未配置'}")
    logger.info(f"  - STT_APP_ID: {'✅ 已配置' if settings.STT_APP_ID else '❌ 未配置'}")

    # 优先使用火山引擎STT服务
    if all([
        settings.STT_ACCESS_KEY,
        settings.STT_SECRET_KEY,
        settings.STT_APP_ID,
    ]):
        logger.info("✅ 使用火山引擎STT服务")

        # 获取服务器URL（用于生成音频文件访问链接）
        server_url = getattr(settings, 'SERVER_URL', None)
        if server_url:
            logger.info(f"  - SERVER_URL: {server_url}")
        else:
            logger.warning("⚠️  SERVER_URL 未配置，将尝试自动获取")

        # 获取语言配置（默认中文）
        language = getattr(settings, 'STT_LANGUAGE', 'zh')
        logger.info(f"  - STT_LANGUAGE: {language} (zh=中文, en=英文, yue=粤语)")

        logger.info("=" * 60)
        return VolcengineSTTService(
            app_id=settings.STT_APP_ID,
            access_key=settings.STT_ACCESS_KEY,
            secret_key=settings.STT_SECRET_KEY,
            resource_id="volc.seedasr.auc",  # 使用标准版模型2.0
            base_url=server_url,
            language=language  # 设置语言
        )
    else:
        logger.warning("⚠️  STT API未完全配置，使用模拟服务")
        logger.info("提示: 在.env文件中配置STT_ACCESS_KEY、STT_SECRET_KEY和STT_APP_ID以启用真实服务")
        logger.info("=" * 60)
        return MockSTTService()


async def transcribe_audio(audio_path: str, service: Optional[STTService] = None) -> str:
    """
    便捷函数：转写音频文件

    Args:
        audio_path: 音频文件路径
        service: STT服务实例（可选，默认使用get_stt_service()）

    Returns:
        转写后的文本

    Examples:
        >>> # 使用默认服务
        >>> text = await transcribe_audio("audio.mp3")
        >>>
        >>> # 使用自定义服务
        >>> service = VolcengineSTTService(app_id="...", access_key="...")
        >>> text = await transcribe_audio("audio.mp3", service=service)
    """
    if service is None:
        service = get_stt_service()

    return await service.transcribe(audio_path)


async def transcribe_audio_verbose(audio_path: str) -> Dict[str, Any]:
    """
    便捷函数：转写音频文件并返回详细信息

    Args:
        audio_path: 音频文件路径

    Returns:
        包含详细信息的字典
    """
    service = get_stt_service()
    return await service.transcribe_with_details(audio_path)


# 测试代码
async def main():
    """测试STT服务"""
    # 测试模拟服务
    print("\n" + "=" * 60)
    print("测试模拟STT服务")
    print("=" * 60)
    mock_service = MockSTTService()
    result = await mock_service.transcribe("test.mp3")
    print(f"结果: {result}")

    # 测试火山引擎服务（需要配置）
    print("\n" + "=" * 60)
    print("测试火山引擎STT服务")
    print("=" * 60)

    service = get_stt_service()

    if isinstance(service, VolcengineSTTService):
        print("使用火山引擎服务")
        # 注意：需要提供真实的音频文件路径
        # result = await service.transcribe("path/to/audio.mp3")
        # print(f"识别结果: {result}")

        # 获取详细信息
        # details = await service.transcribe_with_details("path/to/audio.mp3")
        # print(f"详细信息: {json.dumps(details, ensure_ascii=False, indent=2)}")
    else:
        print("使用模拟服务（未配置火山引擎API）")
        result = await service.transcribe("test.mp3")
        print(f"结果: {result}")


if __name__ == "__main__":
    asyncio.run(main())

