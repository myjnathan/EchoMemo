import httpx
from config import settings
import json
from typing import Dict, List

class LLMService:
    async def analyze(self, text: str) -> dict:
        """
        Returns a dict with:
        - summary: str (legacy, for backward compatibility)
        - structured_summary: dict (Phase 2)
            - core_message: str
            - key_points: list[str]
            - action_items: list[str]
            - topics: list[str]
        - tags: list[str]
        - mood_score: float
        - mood_label: str
        """
        raise NotImplementedError

class MockLLMService(LLMService):
    async def analyze(self, text: str) -> dict:
        return {
            "summary": "这是一个模拟的摘要。用户表达了想去公园的想法。",
            "structured_summary": {
                "core_message": "用户想要去公园放松心情",
                "key_points": [
                    "想去公园散步",
                    "希望改善心情",
                    "计划周末去"
                ],
                "action_items": [
                    "确定去哪个公园",
                    "查看天气情况",
                    "邀请朋友同行"
                ],
                "topics": ["休闲", "健康", "社交"]
            },
            "tags": ["生活", "休闲", "心情"],
            "mood_score": 0.8,
            "mood_label": "Happy"
        }

class DeepSeekLLMService(LLMService):
    def __init__(self, api_key: str, base_url: str):
        self.api_key = api_key
        self.base_url = base_url

    async def analyze(self, text: str) -> dict:
        if not self.api_key:
            return await MockLLMService().analyze(text)

        system_prompt = """
        你是一个语音日记应用的AI助手。
        分析给定的文本，返回一个JSON对象，包含以下字段：

        1. summary: 简洁的中文摘要（最多50个字符）

        2. structured_summary: 结构化摘要对象
           - core_message: 一句话概括用户的核心意图或想法（最多30个字符）
           - key_points: 从文本中提取3-5个关键点，每点10-20个字符
           - action_items: 如果文本中提到要做什么，提取2-4个具体行动项；如果没有，返回空数组
           - topics: 从文本中提取2-4个主题词

        3. tags: 1-3个中文关键词列表
        4. mood_score: -1.0（消极）到1.0（积极）的浮点数
        5. mood_label: 一个词语描述情绪（例如：开心、焦虑、平静、兴奋、疲惫等）

        请只返回有效的JSON格式，不要包含其他文本。
        """

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "deepseek-chat",
                        "messages": [
                            {"role": "system", "content": system_prompt},
                            {"role": "user", "content": text}
                        ],
                        "response_format": {"type": "json_object"}
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                data = response.json()
                content = data["choices"][0]["message"]["content"]
                result = json.loads(content)

                # 确保structured_summary存在
                if "structured_summary" not in result:
                    result["structured_summary"] = {
                        "core_message": result.get("summary", "")[:30],
                        "key_points": [],
                        "action_items": [],
                        "topics": result.get("tags", [])
                    }

                return result
            except Exception as e:
                print(f"LLM Error: {e}")
                # Fallback to mock
                return await MockLLMService().analyze(text)

def get_llm_service():
    if settings.LLM_API_KEY:
        return DeepSeekLLMService(settings.LLM_API_KEY, settings.LLM_BASE_URL)
    return MockLLMService()
