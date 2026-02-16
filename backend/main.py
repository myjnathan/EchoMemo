from fastapi import FastAPI, Depends, UploadFile, File, BackgroundTasks, HTTPException, status
# from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm  # 已禁用：移除认证依赖
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
import aiofiles
import os
import shutil
import logging
from typing import List
from datetime import timedelta
from database import SessionLocal

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()  # 输出到stdout，docker logs可以捕获
    ]
)

# 获取logger
logger = logging.getLogger(__name__)

from config import settings
from database import engine, Base, get_db
import models
import schemas
from services.stt import get_stt_service
from services.llm import get_llm_service
# from auth import create_access_token, get_password_hash, verify_password  # 已禁用：移除认证依赖
from auth import get_password_hash  # 保留：用于创建默认用户
# from jose import JWTError, jwt  # 已禁用：移除JWT依赖

# Create Tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION
)

# 挂载静态文件服务（用于音频文件访问）
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

# oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")  # 已禁用：移除认证依赖

# 已禁用：移除认证依赖 - 保留默认用户模式
# async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
#     credentials_exception = HTTPException(
#         status_code=status.HTTP_401_UNAUTHORIZED,
#         detail="Could not validate credentials",
#         headers={"WWW-Authenticate": "Bearer"},
#     )
#     try:
#         payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
#         username: str = payload.get("sub")
#         if username is None:
#             raise credentials_exception
#         token_data = schemas.TokenData(username=username)
#     except JWTError:
#         raise credentials_exception
#     user = db.query(models.User).filter(models.User.username == token_data.username).first()
#     if user is None:
#         raise credentials_exception
#     return user

# 已禁用：移除认证路由
# @app.post("/token", response_model=schemas.Token)
# async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
#     user = db.query(models.User).filter(models.User.username == form_data.username).first()
#     if not user or not verify_password(form_data.password, user.hashed_password):
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Incorrect username or password",
#             headers={"WWW-Authenticate": "Bearer"},
#         )
#     access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
#     access_token = create_access_token(
#         data={"sub": user.username}, expires_delta=access_token_expires
#     )
#     return {"access_token": access_token, "token_type": "bearer"}

# @app.post("/users/", response_model=schemas.UserResponse)
# def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
#     db_user = db.query(models.User).filter(models.User.username == user.username).first()
#     if db_user:
#         raise HTTPException(status_code=400, detail="Username already registered")
#     hashed_password = get_password_hash(user.password)
#     db_user = models.User(username=user.username, hashed_password=hashed_password)
#     db.add(db_user)
#     db.commit()
#     db.refresh(db_user)
#     return db_user

# ============================================
# 创建默认用户（MVP模式）
# ============================================
def create_default_user(db: Session):
    """创建默认用户（id=1），用于MVP单用户模式"""
    default_user = db.query(models.User).filter(models.User.id == 1).first()
    if not default_user:
        default_user = models.User(
            id=1,
            username="default_user",
            hashed_password=get_password_hash("default_password")
        )
        db.add(default_user)
        db.commit()
        logger.info("✅ Created default user (id=1, username='default_user')")
    else:
        logger.info("ℹ️  Default user already exists (id=1)")

@app.on_event("startup")
async def startup_event():
    """应用启动时创建默认用户"""
    db = SessionLocal()
    try:
        create_default_user(db)
    finally:
        db.close()
# ============================================

@app.get("/")
async def root():
    return {"message": "Welcome to EchoMemo API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

async def process_memo(memo_id: int, audio_path: str):
    import logging
    logger = logging.getLogger(__name__)

    logger.info("=" * 80)
    logger.info(f"🎤 开始处理 Memo #{memo_id}")
    logger.info(f"音频文件: {audio_path}")
    logger.info("=" * 80)

    try:
        # 1. STT (语音转文字)
        logger.info("\n[1/3] 📝 开始STT语音转文字...")
        stt_service = get_stt_service()
        logger.info(f"使用服务: {type(stt_service).__name__}")

        transcription = await stt_service.transcribe(audio_path)

        logger.info("\n✅ STT转写完成!")
        logger.info(f"转写结果 ({len(transcription)} 字符):")
        logger.info("-" * 80)
        logger.info(transcription)
        logger.info("-" * 80)

        # 2. LLM Analysis
        logger.info("\n[2/3] 🤖 开始LLM智能分析...")
        llm_service = get_llm_service()
        logger.info(f"使用服务: {type(llm_service).__name__}")

        analysis = await llm_service.analyze(transcription)

        logger.info("\n✅ LLM分析完成!")
        logger.info("分析结果:")
        logger.info(f"  - 摘要: {analysis.get('summary', 'N/A')}")
        logger.info(f"  - 标签: {analysis.get('tags', [])}")
        logger.info(f"  - 情感: {analysis.get('mood_label', 'N/A')} ({analysis.get('mood_score', 0)})")

        # 3. Update DB
        logger.info("\n[3/3] 💾 更新数据库...")
        from database import SessionLocal
        bg_db = SessionLocal()
        try:
            memo = bg_db.query(models.Memo).filter(models.Memo.id == memo_id).first()
            if memo:
                memo.transcription = transcription
                memo.summary = analysis.get("summary")
                memo.tags = analysis.get("tags")
                memo.mood_score = analysis.get("mood_score")
                memo.mood_label = analysis.get("mood_label")
                memo.status = "completed"
                bg_db.commit()
                logger.info(f"✅ Memo #{memo_id} 更新成功!")
            else:
                logger.error(f"❌ 找不到 Memo #{memo_id}")
        finally:
            bg_db.close()

        logger.info("\n" + "=" * 80)
        logger.info(f"🎉 Memo #{memo_id} 处理完成!")
        logger.info("=" * 80)

    except Exception as e:
        logger.error(f"\n❌ 处理 Memo #{memo_id} 时出错: {e}")
        import traceback
        logger.error(traceback.format_exc())

        from database import SessionLocal
        bg_db = SessionLocal()
        try:
            memo = bg_db.query(models.Memo).filter(models.Memo.id == memo_id).first()
            if memo:
                memo.status = "failed"
                bg_db.commit()
                logger.info(f"已标记 Memo #{memo_id} 为失败状态")
        finally:
            bg_db.close()

@app.post("/upload", response_model=schemas.MemoResponse)
async def upload_audio(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
    # MVP模式：移除认证依赖，所有memo关联到默认用户（id=1）
    # current_user: models.User = Depends(get_current_user)
):
    # Ensure filename is safe or generate UUID
    # For now, just use original filename
    file_path = os.path.join(settings.UPLOAD_DIR, file.filename)

    async with aiofiles.open(file_path, 'wb') as out_file:
        content = await file.read()
        await out_file.write(content)

    # Create DB Entry - MVP模式：使用默认用户ID=1
    new_memo = models.Memo(
        audio_path=file_path,
        status="processing",
        user_id=1  # MVP模式：硬编码使用默认用户
    )
    db.add(new_memo)
    db.commit()
    db.refresh(new_memo)

    # Trigger Background Task
    background_tasks.add_task(process_memo, new_memo.id, file_path)

    return new_memo

@app.get("/memos", response_model=List[schemas.MemoResponse])
async def get_memos(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
    # MVP模式：移除认证依赖，查询默认用户（id=1）的memo
    # current_user: models.User = Depends(get_current_user)
):
    # MVP模式：硬编码查询默认用户（id=1）
    memos = db.query(models.Memo)\
        .filter(models.Memo.user_id == 1)\
        .order_by(models.Memo.created_at.desc())\
        .offset(skip).limit(limit).all()
    return memos

@app.get("/memos/{memo_id}", response_model=schemas.MemoResponse)
async def get_memo(
    memo_id: int,
    db: Session = Depends(get_db)
    # MVP模式：移除认证依赖，查询默认用户（id=1）的memo
    # current_user: models.User = Depends(get_current_user)
):
    # MVP模式：硬编码查询默认用户（id=1）
    memo = db.query(models.Memo)\
        .filter(models.Memo.id == memo_id, models.Memo.user_id == 1)\
        .first()
    if not memo:
        raise HTTPException(status_code=404, detail="Memo not found")
    return memo
