from pydantic import BaseModel
from typing import Optional, List, Any, Dict
from datetime import datetime

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserCreate(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class MemoBase(BaseModel):
    pass

class MemoCreate(MemoBase):
    pass  # Usually handled via file upload

class MemoUpdate(BaseModel):
    """Memo更新schema - 支持部分更新"""
    transcription: Optional[str] = None
    summary: Optional[str] = None
    tags: Optional[List[str]] = None

class StructuredSummary(BaseModel):
    """结构化摘要schema (Phase 2)"""
    core_message: Optional[str] = None  # 一句话核心信息
    key_points: List[str] = []  # 关键点列表
    action_items: List[str] = []  # 行动项列表
    topics: List[str] = []  # 主题列表

class MemoResponse(BaseModel):
    id: int
    audio_path: str
    transcription: Optional[str] = None
    summary: Optional[str] = None  # Legacy summary (for backward compatibility)
    structured_summary: Optional[StructuredSummary] = None  # Phase 2 structured summary
    tags: Optional[List[str]] = []
    mood_score: Optional[float] = None
    mood_label: Optional[str] = None
    status: str
    embedding: Optional[List[float]] = None  # Phase 2: text embedding vector
    related_memo_ids: Optional[List[int]] = None  # Phase 2: related memo IDs (nullable for backward compatibility)
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
