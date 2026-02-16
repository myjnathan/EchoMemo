import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    PROJECT_NAME = "EchoMemo"
    VERSION = "0.1.0"
    API_PREFIX = "/api/v1"

    # Database
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

    # Security
    SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = 30

    # API Keys (Domestic)
    # Volcengine (ByteDance) or Aliyun for STT
    STT_SECRET_KEY = os.getenv("STT_SECRET_KEY", "")
    STT_ACCESS_KEY = os.getenv("STT_ACCESS_KEY", "")
    STT_APP_ID = os.getenv("STT_APP_ID", "")

    # STT Language (语音识别语言)
    # zh: 中文, en: 英文, yue: 粤语
    STT_LANGUAGE = os.getenv("STT_LANGUAGE", "zh")

    # Server URL (用于生成音频文件的公网访问链接)
    # 示例：http://your-domain.com 或 http://123.45.67.89:8000
    # 如果不配置，将尝试自动从请求中获取
    SERVER_URL = os.getenv("SERVER_URL", "")

    # LLM (DeepSeek or similar OpenAI compatible)
    LLM_API_KEY = os.getenv("LLM_API_KEY", "")
    LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://api.deepseek.com/v1")

    # Storage
    UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")

settings = Config()

# Ensure upload directory exists
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
