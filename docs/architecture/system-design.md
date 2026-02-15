# EchoMemo System Design / 系统设计文档

**Last Updated**: 2025-02-15
**Version**: v1.0.0

---

## 📐 System Architecture / 系统架构

### High-Level Architecture / 高层架构

```
┌─────────────────────────────────────────────────────────┐
│                    User Layer / 用户层                   │
│  iOS App │ Android App │ macOS App │ Web App (Future)  │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTPS / WSS
                      ↓
┌──────────────────────────────────────────────────────────┐
│               API Gateway / API 网关                    │
│         (Nginx / ALB / Cloudflare - Phase 3+)           │
└─────────────────────┬──────────────────────────────────┘
                      │
        ┌─────────────┴──────────────┐
        ↓                              ↓
┌──────────────────┐         ┌──────────────────┐
│  Flutter State   │         │  WebSocket      │
│   Management     │         │   Server         │
│  (Provider)      │         │  (FastAPI)       │
└──────────────────┘         └────────┬─────────┘
                                       │
                    ┌──────────────────┴─────────┐
                    ↓                              ↓
            ┌──────────────┐            ┌──────────────┐
            │   Services   │            │   Database   │
            │   Layer      │            │   (Postgres) │
            ├──────────────┤            └──────────────┘
            │ STT Service  │                     ↑
            │ LLM Service  │             ┌─────┴──────┐
            │ Embedding    │             │    File    │
            │ Emotion      │             │  Storage   │
            │ Reflection   │             └────────────┘
            └──────────────┘
```

---

## Component Details / 组件详情

### Frontend Components / 前端组件

#### 1. State Management / 状态管理

```dart
// lib/core/providers/app_providers.dart

/// Main application providers
class AppProviders {
  static List<SingleChildWidget> get all => [
    ChangeNotifierProvider(create: (_) => ApiService()),
    ChangeNotifierProvider(create: (_) => AudioRecorderService()),
    ChangeNotifierProvider(create: (_) => TranscriptionStreamService()),
    ChangeNotifierProvider(create: (_) => StorageService()),
    ChangeNotifierProvider(create: (_) => EncryptionService()),
  ];
}

/// Usage in main.dart
void main() {
  runApp(
    MultiProvider(
      providers: AppProviders.all,
      child: EchoMemoApp(),
    ),
  );
}
```

#### 2. Service Layer Architecture / 服务层架构

```dart
// lib/core/services/base_service.dart

/// Base service interface
abstract class BaseService {
  Future<void> initialize();
  Future<void> dispose();
  bool get isInitialized;
}

/// Audio Recording Service
class AudioRecorderService extends BaseService {
  final Recorder _recorder = Recorder();
  bool _isInitialized = false;
  StreamController<Uint8List>? _audioStreamController;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _recorder.initialize();
    _isInitialized = true;
  }

  Future<void> startRecording() async {
    if (!_isInitialized) await initialize();

    _audioStreamController = StreamController<Uint8List>.broadcast();

    await _recorder.start(
      StreamConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
      ),
    );
  }

  Stream<Uint8List> get audioStream =>
      _audioStreamController!.stream;
}

/// Transcription Streaming Service
class TranscriptionStreamService extends BaseService {
  WebSocketChannel? _channel;
  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();

  Future<void> connect(String sessionId) async {
    final wsUrl = Uri.parse(
      '${ApiService.baseUrl}/v1/transcribe/stream?session_id=$sessionId'
    );
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (data) {
        final response = jsonDecode(data);
        _transcriptionController.add(response['text']);
      },
      onError: (error) => print('Stream error: $error'),
      onDone: () => print('Stream closed'),
    );
  }

  Stream<String> get transcriptionStream =>
      _transcriptionController.stream;

  Future<void> sendAudioChunk(Uint8List chunk) async {
    _channel?.sink.add(chunk);
  }
}
```

### Backend Components / 后端组件

#### 1. API Route Structure / API路由结构

```python
# backend/api/v1/__init__.py

from fastapi import APIRouter
from .capsules import router as capsules_router
from .streaming import router as streaming_router
from .context import router as context_router

api_router = APIRouter()

api_router.include_router(capsules_router, prefix="/capsules", tags=["capsules"])
api_router.include_router(streaming_router, prefix="/transcribe", tags=["streaming"])
api_router.include_router(context_router, prefix="/context", tags=["context"])

# backend/main.py

from fastapi import FastAPI
from api.v1 import api_router

app = FastAPI(title="EchoMemo API")
app.include_router(api_router, prefix="/v1")
```

#### 2. Service Layer / 服务层

```python
# backend/services/base_service.py

from abc import ABC, abstractmethod

class BaseService(ABC):
    """Base class for all services"""

    @abstractmethod
    async def initialize(self):
        """Initialize service resources"""
        pass

    @abstractmethod
    async def shutdown(self):
        """Cleanup service resources"""
        pass

# backend/services/stt/base_stt.py

class BaseSTTService(BaseService):
    """Base class for STT services"""

    @abstractmethod
    async def transcribe(self, audio_path: str) -> str:
        """Transcribe audio file"""
        pass

    @abstractmethod
    async def stream_transcribe(
        self,
        audio_stream: AsyncIterator[bytes]
    ) -> AsyncIterator[str]:
        """Stream transcription"""
        pass

# backend/services/stt/volcengine_stt.py

class VolcengineSTTService(BaseSTTService):
    """Volcengine STT implementation"""

    def __init__(self, config: STTConfig):
        self.app_id = config.app_id
        self.access_key = config.access_key
        self.secret_key = config.secret_key

    async def transcribe(self, audio_path: str) -> str:
        # Submit task
        task_id = await self._submit_task(audio_path)

        # Poll for result
        while True:
            result = await self._query_task(task_id)
            if result.status == "completed":
                return result.text
            elif result.status == "failed":
                raise STTException(result.error)
            await asyncio.sleep(1)
```

#### 3. Database Layer / 数据库层

```python
# backend/database.py

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from contextlib import asynccontextmanager

class Database:
    def __init__(self, database_url: str):
        self.engine = create_async_engine(
            database_url,
            echo=False,
            pool_size=20,
            max_overflow=10,
            pool_pre_ping=True,
        )
        self.SessionLocal = sessionmaker(
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

    @asynccontextmanager
    async def get_session(self):
        async with self.SessionLocal() as session:
            try:
                yield session
            finally:
                await session.close()

# Usage in services

db = Database(settings.DATABASE_URL)

async def create_capsule(capsule_data: CapsuleCreate):
    async with db.get_session() as session:
        capsule = ThoughtCapsule(**capsule_data.dict())
        session.add(capsule)
        await session.commit()
        await session.refresh(capsule)
        return capsule
```

---

## Data Models / 数据模型

### Core Entities / 核心实体

```python
# backend/models/capsule.py

class ThoughtCapsule(Base):
    """Core data model for voice memos"""
    __tablename__ = "thought_capsules"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    # Audio data
    audio_path = Column(String(255), nullable=False)
    duration_seconds = Column(Integer)
    file_size_bytes = Column(BigInteger)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Processing status
    transcription_status = Column(String(20), default="processing")

    # Relationships
    transcription_blocks = relationship("TranscriptionBlock", back_populates="capsule")
    context_metadata = relationship("CapsuleContext", back_populates="capsule")
    emotion_report = relationship("EmotionReport", back_populates="capsule", uselist=False)

class TranscriptionBlock(Base):
    """Streaming transcription chunks"""
    __tablename__ = "transcription_blocks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    capsule_id = Column(UUID(as_uuid=True), ForeignKey("thought_capsules.id"))
    block_order = Column(Integer, nullable=False)
    text = Column(Text, nullable=False)
    confidence = Column(Numeric(5, 3))
    is_final = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=func.now())

    capsule = relationship("ThoughtCapsule", back_populates="transcription_blocks")

class CapsuleContext(Base):
    """Context metadata for capsules"""
    __tablename__ = "capsule_context"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    capsule_id = Column(UUID(as_uuid=True), ForeignKey("thought_capsules.id"))
    context_type = Column(String(50), nullable=False)  # location, activity, weather
    context_data = Column(JSONB, nullable=False)
    captured_at = Column(DateTime(timezone=True), default=func.now())

    capsule = relationship("ThoughtCapsule", back_populates="context_metadata")
```

---

## API Design / API设计

### RESTful Endpoints / RESTful端点

#### Capsules API / 胶囊API

```http
### Create Capsule (Upload Audio)
POST /v1/capsules
Content-Type: multipart/form-data

Request:
{
  "audio": <binary audio data>,
  "context": {
    "location_lat": 39.9042,
    "location_lng": 116.4074,
    "activity_type": "walking"
  }
}

Response: 201 Created
{
  "id": "uuid",
  "audio_path": "/capsules/uuid.m4a",
  "status": "processing",
  "created_at": "2025-02-15T10:30:00Z"
}

### List Capsules (Timeline)
GET /v1/capsules?limit=20&offset=0

Response: 200 OK
{
  "capsules": [
    {
      "id": "uuid",
      "duration": 120,
      "created_at": "2025-02-15T10:30:00Z",
      "transcription": "Hello world...",
      "context": {
        "location": "Beijing, China",
        "activity": "walking"
      }
    }
  ],
  "total": 150,
  "has_more": true
}

### Get Capsule Details
GET /v1/capsules/{capsule_id}

Response: 200 OK
{
  "id": "uuid",
  "audio_url": "/capsules/uuid.m4a",
  "duration": 120,
  "transcription": "Full transcription...",
  "transcription_blocks": [
    {
      "text": "Hello",
      "is_final": true,
      "timestamp": "2025-02-15T10:30:01Z"
    }
  ],
  "emotion": {
    "primary": "neutral",
    "intensity": 0.5
  }
}

### Delete Capsule
DELETE /v1/capsules/{capsule_id}

Response: 204 No Content
```

### WebSocket Endpoint / WebSocket端点

```http
### Streaming Transcription
WS /v1/transcribe/stream?session_id={session_id}&token={jwt_token}

Connection Flow:
1. Client connects with session_id
2. Client sends audio chunks (binary)
3. Server responds with transcription (JSON)

Client → Server (binary audio chunk)
Server → Client:
{
  "text": "Hello",
  "is_final": false,
  "timestamp": "2025-02-15T10:30:01Z"
}

Server → Client (later):
{
  "text": "Hello world",
  "is_final": true,
  "timestamp": "2025-02-15T10:30:02Z"
}
```

---

## Security Architecture / 安全架构

### Encryption Strategy / 加密策略

```
┌─────────────────────────────────────┐
│     Client (Flutter App)            │
│                                     │
│  1. User records audio              │
│  2. Audio encrypted with AES-256-GCM │
│     Key: Device-specific            │
│  3. Encrypted audio stored locally   │
└─────────────┬───────────────────────┘
              │
              │ Upload (optional)
              ↓
┌─────────────────────────────────────┐
│     Server (Backend)                │
│                                     │
│  4. Server never sees plaintext      │
│     audio (only encrypted blob)      │
│  5. Transcription returned          │
│  6. Client decrypts and displays     │
└─────────────────────────────────────┘
```

### Key Management / 密钥管理

```dart
// Frontend key storage

class SecureKeyService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String> getOrCreateKey() async {
    String? key = await _storage.read(key: 'encryption_key');

    if (key == null) {
      key = _generateKey();
      await _storage.write(key: 'encryption_key', value: key);
    }

    return key;
  }

  String _generateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(values);
  }
}
```

### Authentication / 认证

```python
# backend/auth.py

from jose import JWTError, jwt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.now() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str, db: AsyncSession):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = await db.execute(select(User).filter(User.username == username))
    return user.scalar_one()
```

---

## Performance Optimization / 性能优化

### Frontend Optimizations / 前端优化

```dart
// 1. Const constructors
const MyApp();  // Good

// 2. Lazy loading
import 'screens/settings_screen.dart' deferred;

// 3. Repaint boundary
class RecordingScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: WaveformVisualizer(),  // Only this repaints
    );
  }
}

// 4. Cached network image
CachedNetworkImage(
  imageUrl: avatarUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
)

// 5. AutomaticKeepAliveClientMixin
class TimelineList extends StatefulWidget {
  // Don't recreate when scrolling
}
```

### Backend Optimizations / 后端优化

```python
# 1. Database connection pooling

engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,        # More connections
    max_overflow=10,      # Extra during peak
    pool_pre_ping=True,   # Verify connections
)

# 2. Query optimization

# ✅ Good: Select only needed columns
stmt = select(ThoughtCapsule.id, ThoughtCapsule.created_at)

# ❌ Bad: Select all columns
stmt = select(ThoughtCapsule)

# 3. Eager loading for relationships

stmt = select(ThoughtCapsule).options(
    selectinload(ThoughtCapsule.transcription_blocks)
)

# 4. Indexing

CREATE INDEX idx_user_created_desc ON thought_capsules(user_id, created_at DESC);
CREATE INDEX idx_status ON thought_capsules(transcription_status)
  WHERE transcription_status = 'processing';

# 5. Caching

from functools import lru_cache

@lru_cache(maxsize=100)
async def get_user_settings(user_id: str):
    return await fetch_settings(user_id)
```

---

## Scalability Strategy / 扩展策略

### Phase 1 (1-1000 users) / 第一阶段

```
Single VPS (4-8 GB RAM)
  ├─ FastAPI (4 workers)
  ├─ PostgreSQL (1 instance)
  └─ File storage (local disk)
```

### Phase 2 (1000-10000 users) / 第二阶段

```
Load Balancer (ALB/Nginx)
  ├─ Backend Server 1 (API + Recording)
  ├─ Backend Server 2 (Analysis + AI)
  └─ Database (Primary + Replica)
      ├─ Redis (Cache + Queue)
      └─ File Storage (CDN)
```

### Phase 3-4 (10000+ users) / 第三-四阶段

```
Microservices Architecture:
  ├─ API Gateway
  ├─ Auth Service
  ├─ Recording Service (Stateless)
  ├─ Transcription Service (GPU for STT)
  ├─ Analysis Service (CPU for LLM)
  ├─ Dialogue Service (GPU for LLM)
  └─ Database Cluster
      ├─ Primary (PostgreSQL)
      ├─ Replicas (Read replicas)
      ├─ Vector DB (Pinecone/Weaviate)
      └─ Cache (Redis Cluster)
```

---

## Monitoring & Observability / 监控和可观察性

### Logging Strategy / 日志策略

```python
# backend/core/logging.py

import logging
import structlog

# Structured logging
logger = structlog.get_logger()

# Usage
logger.info(
    "capsule_created",
    capsule_id=capsule.id,
    user_id=capsule.user_id,
    duration=capsule.duration_seconds
)

# Output:
# {"event": "capsule_created", "capsule_id": "uuid", "user_id": "uuid", "duration": 120, "timestamp": "2025-02-15T10:30:00Z"}
```

### Metrics Collection / 指标收集

```python
# backend/core/metrics.py

from prometheus_client import Counter, Histogram, Gauge

# Define metrics
capsules_created = Counter('capsules_created_total', 'Total capsules created')
recording_duration = Histogram('recording_duration_seconds', 'Recording duration')
active_users = Gauge('active_users', 'Currently active users')

# Usage
@app.post("/v1/capsules")
async def create_capsule():
    capsules_created.inc()
    recording_duration.observe(capsule.duration)
```

---

## Testing Strategy / 测试策略

### Frontend Testing / 前端测试

```dart
// Unit tests
test('AudioRecorder initializes correctly', () {
  final recorder = AudioRecorderService();
  expect(recorder.isInitialized, false);
  expect(recorder.initialize(), completes);
  expect(recorder.isInitialized, true);
});

// Widget tests
testWidgets('RecordingScreen displays microphone button', (tester) async {
  await tester.pumpWidget(MaterialApp(home: RecordingScreen()));
  expect(find.byType(IconButton), findsOneWidget);
});

// Integration tests
testWidgets('Full recording flow works', (tester) async {
  await tester.pumpWidget(EchoMemoApp());

  await tester.tap(find.byType(IconButton));
  await tester.pumpAndSettle();

  expect(find.text('Recording...'), findsOneWidget);
});
```

### Backend Testing / 后端测试

```python
# Unit tests
@pytest.mark.asyncio
async def test_create_capsule():
    capsule_data = CapsuleCreate(
        audio_path="/test/audio.m4a",
        user_id=test_user_id
    )
    capsule = await create_capsule(capsule_data)

    assert capsule.user_id == test_user_id
    assert capsule.status == "processing"

# Integration tests
@pytest.mark.asyncio
async def test_full_transcription_flow():
    # Upload audio
    capsule = await upload_audio(test_audio_file)

    # Wait for processing
    await asyncio.sleep(5)

    # Check transcription
    updated = await get_capsule(capsule.id)
    assert updated.transcription is not None
    assert updated.status == "completed"
```

---

## Related Documents / 相关文档

- [API Specifications](./api-design.md) - To be created
- [Database Schema](./database-schema.md) - To be created
- [Technical Roadmap](./tech-roadmap.md)

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
**Maintained By**: EchoMemo Tech Team
