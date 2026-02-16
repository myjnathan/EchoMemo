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
    summary = Column(String, nullable=True)  # LLM Summary (legacy, for backward compatibility)

    # Enhanced structured summary (Phase 2)
    structured_summary = Column(JSON, nullable=True)  # {
    #   "core_message": "One sentence core idea",
    #   "key_points": ["point 1", "point 2", ...],
    #   "action_items": ["item 1", "item 2", ...],
    #   "topics": ["topic 1", "topic 2", ...]
    # }

    tags = Column(JSON, default=[])  # Extracted tags
    mood_score = Column(Float, nullable=True)  # Sentiment score (-1 to 1)
    mood_label = Column(String, nullable=True) # e.g., "Happy", "Anxious"

    # Semantic analysis fields (Phase 2)
    embedding = Column(JSON, nullable=True)  # Text embedding vector for similarity search
    related_memo_ids = Column(JSON, default=[])  # List of related memo IDs

    status = Column(String, default="pending")  # pending, processing, completed, failed

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
