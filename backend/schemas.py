from pydantic import BaseModel
from typing import Optional, List, Any
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

class MemoResponse(BaseModel):
    id: int
    audio_path: str
    transcription: Optional[str] = None
    summary: Optional[str] = None
    tags: Optional[List[str]] = []
    mood_score: Optional[float] = None
    mood_label: Optional[str] = None
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
