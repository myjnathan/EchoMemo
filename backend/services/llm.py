import httpx
from config import settings
import json

class LLMService:
    async def analyze(self, text: str) -> dict:
        """
        Returns a dict with:
        - summary: str
        - tags: list[str]
        - mood_score: float
        - mood_label: str
        """
        raise NotImplementedError

class MockLLMService(LLMService):
    async def analyze(self, text: str) -> dict:
        return {
            "summary": "这是一个模拟的摘要。用户表达了想去公园的想法。",
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
        You are an AI assistant for a voice journal app.
        Analyze the given text and return a JSON object with:
        1. summary: A concise summary (max 50 chars).
        2. tags: A list of 1-3 keywords.
        3. mood_score: A float from -1.0 (negative) to 1.0 (positive).
        4. mood_label: One word description of the mood (e.g., Happy, Anxious, Calm).
        
        Return ONLY valid JSON.
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
                return json.loads(content)
            except Exception as e:
                print(f"LLM Error: {e}")
                # Fallback to mock
                return await MockLLMService().analyze(text)

def get_llm_service():
    if settings.LLM_API_KEY:
        return DeepSeekLLMService(settings.LLM_API_KEY, settings.LLM_BASE_URL)
    return MockLLMService()
