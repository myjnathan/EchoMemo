from sqlalchemy import Column, Integer, String, DateTime, JSON, ForeignKey, Float
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Memo(Base):
    __tablename__ = "memos"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    audio_path = Column(String)  # Path to local file or URL
    transcription = Column(String, nullable=True)  # Raw STT result
    summary = Column(String, nullable=True)  # LLM Summary
    tags = Column(JSON, default=[])  # Extracted tags
    mood_score = Column(Float, nullable=True)  # Sentiment score (-1 to 1)
    mood_label = Column(String, nullable=True) # e.g., "Happy", "Anxious"
    
    status = Column(String, default="pending")  # pending, processing, completed, failed
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
