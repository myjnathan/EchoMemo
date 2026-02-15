# EchoMemo Coding Standards & Development Guide / 代码规范与开发指南

**Last Updated**: 2025-02-15
**Version**: v1.0.0
**Status**: ✅ Active

---

## 📋 Table of Contents / 目录

1. [Overview / 概述](#overview--概述)
2. [Flutter/Dart Standards / FlutterDart规范](#flutterdart-standards--flutterdart规范)
3. [Python/FastAPI Standards / PythonFastAPI规范](#pythonfastapi-standards--pythonfastapi规范)
4. [Git Workflow / Git工作流](#git-workflow--git工作流)
5. [Testing Standards / 测试规范](#testing-standards--测试规范)
6. [Code Review Checklist / 代码审查清单](#code-review-checklist--代码审查清单)
7. [Performance Guidelines / 性能指南](#performance-guidelines--性能指南)
8. [Security Standards / 安全规范](#security-standards--安全规范)
9. [Documentation Standards / 文档规范](#documentation-standards--文档规范)
10. [Development Workflow / 开发工作流](#development-workflow--开发工作流)

---

## Overview / 概述

This document defines the mandatory coding standards, rules, and best practices for EchoMemo development. All team members must follow these standards to ensure code quality, maintainability, and security.

本文档定义了EchoMemo开发的强制性代码规范、规则和最佳实践。所有团队成员必须遵循这些规范以确保代码质量、可维护性和安全性。

### Core Principles / 核心原则

1. **Privacy First / 隐私优先**: User data is sacred. Encrypt everything.
2. **Performance Matters / 性能至上**: Target <1.5s launch, <300ms transcription
3. **Simplicity / 简单即是美**: Avoid over-engineering. Ship fast.
4. **Traceability / 可追溯性**: Every task must be trackable and resumable
5. **Bilingual / 双语**: All code comments and docs must be bilingual

---

## Flutter/Dart Standards / FlutterDart规范

### File Organization / 文件组织

```
lib/
├── main.dart                      # App entry point / 应用入口
├── core/                          # Core functionality / 核心功能
│   ├── constants/                 # Constants / 常量
│   │   └── app_constants.dart
│   ├── providers/                 # State management / 状态管理
│   │   └── app_providers.dart
│   ├── services/                  # Services / 服务
│   │   ├── api_service.dart
│   │   ├── audio_recorder_service.dart
│   │   └── encryption_service.dart
│   ├── utils/                     # Utilities / 工具
│   │   └── logger.dart
│   └── widgets/                   # Shared widgets / 共享组件
│       ├── loading_indicator.dart
│       └── error_display.dart
├── features/                      # Feature modules / 功能模块
│   └── instant_capture/           # Example feature / 示例功能
│       ├── screens/
│       │   └── recording_screen.dart
│       ├── widgets/
│       │   └── waveform_visualizer.dart
│       └── controllers/
│           └── recording_controller.dart
└── models/                        # Data models / 数据模型
    └── memo.dart
```

### Naming Conventions / 命名规范

#### Classes / 类名

✅ **Good / 好的**:
```dart
class AudioRecorderService {}
class WaveformVisualizer {}
class MemoCardWidget {}
```

❌ **Bad / 不好的**:
```dart
class audioRecorder {}  // PascalCase required
class Audio_Recorder {} // No underscores
class recorderService {} // PascalCase required
```

#### Variables & Functions / 变量与函数

✅ **Good / 好的**:
```dart
String userName = 'John';
int recordingDuration = 120;
Future<void> startRecording() async {}
bool isValidTranscription() {}
```

❌ **Bad / 不好的**:
```dart
String UserName = 'John';  // camelCase required
int Recording_Duration = 120; // No underscores
Future<void> StartRecording() {} // camelCase required
```

#### Constants / 常量

✅ **Good / 好的**:
```dart
const double kDefaultPadding = 16.0;
const String kApiBaseUrl = 'https://api.echomemo.com';
const int kMaxRecordingDuration = 300; // seconds / 秒
```

❌ **Bad / 不好的**:
```dart
const double DEFAULT_PADDING = 16.0;  // lowerCamelCase with k prefix
const String defaultPadding = '16.0'; // Missing k prefix
```

#### Private Members / 私有成员

✅ **Good / 好的**:
```dart
class AudioService {
  String _apiKey = '';           // Private / 私有
  Future<void> _initRecorder() {} // Private method / 私有方法
}
```

❌ **Bad / 不好的**:
```dart
class AudioService {
  String apiKey = '';            // Should be private / 应该私有
}
```

### Code Style / 代码风格

#### Formatting / 格式化

Use `dart format` with default settings (2 spaces).

使用默认设置的 `dart format`（2个空格）。

```bash
# Format all files / 格式化所有文件
dart format .

# Format specific file / 格式化特定文件
dart format lib/main.dart
```

#### Line Length / 行长度

- **Maximum / 最大**: 80 characters / 字符
- **Target / 目标**: 60-70 characters / 字符

✅ **Good / 好的**:
```dart
final transcription = await apiService
    .transcribeAudio(audioChunk);
```

❌ **Bad / 不好的**:
```dart
final transcription = await apiService.transcribeAudio(audioChunkThatIsVeryVeryLong);
```

#### Imports / 导入

**Order / 顺序**:
1. Dart SDK / Dart SDK
2. Flutter packages / Flutter包
3. Third-party packages / 第三方包
4. Project files / 项目文件

✅ **Good / 好的**:
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:echomemo/core/services/api_service.dart';
import 'package:echomemo/models/memo.dart';
```

### Widget Patterns / 组件模式

#### Stateless vs Stateful / 无状态 vs 有状态

Prefer `StatelessWidget` whenever possible.

尽可能使用 `StatelessWidget`。

✅ **Use Stateless / 使用无状态**:
```dart
class MemoCard extends StatelessWidget {
  final Memo memo;

  const MemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(memo.transcription ?? 'No text'),
    );
  }
}
```

✅ **Use Stateful / 使用有状态** (only when needed / 仅在需要时):
```dart
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    // Build UI / 构建UI
  }
}
```

#### Const Constructors / Const构造函数

Use `const` wherever possible for performance.

尽可能使用 `const` 以提升性能。

✅ **Good / 好的**:
```dart
const SizedBox(height: 16.0);
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
);
```

❌ **Bad / 不好的**:
```dart
SizedBox(height: 16.0);  // Missing const
Padding(                 // Missing const
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
);
```

#### Keys / 键值

Always add `key` to widgets that will be rebuilt or moved.

为将被重建或移动的组件添加 `key`。

✅ **Good / 好的**:
```dart
ListView.builder(
  itemCount: memos.length,
  itemBuilder: (context, index) {
    return MemoCard(
      key: ValueKey(memos[index].id), // Important / 重要
      memo: memos[index],
    );
  },
);
```

### Async Patterns / 异步模式

#### Error Handling / 错误处理

Always handle async errors properly.

正确处理异步错误。

✅ **Good / 好的**:
```dart
Future<void> startRecording() async {
  try {
    await _recorder.start();
    _isRecording = true;
    notifyListeners();
  } on RecorderException catch (e) {
    _logger.error('Recording failed: $e');
    _showErrorToast('Failed to start recording');
  } catch (e, stackTrace) {
    _logger.error('Unexpected error', e, stackTrace);
    _showErrorToast('An unexpected error occurred');
  }
}
```

❌ **Bad / 不好的**:
```dart
Future<void> startRecording() async {
  await _recorder.start(); // No error handling / 无错误处理
  _isRecording = true;
}
```

#### Loading States / 加载状态

Always show loading indicators for async operations.

为异步操作显示加载指示器。

✅ **Good / 好的**:
```dart
FutureBuilder<Memo>(
  future: _memoFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return ErrorDisplay(snapshot.error.toString());
    }

    final memo = snapshot.data!;
    return MemoCard(memo: memo);
  },
);
```

### Comments / 注释

#### Document Public APIs / 文档化公开API

✅ **Required / 必需**:
```dart
/// Starts audio recording with optional duration limit.
///
/// [duration] Maximum recording duration in seconds. Null for unlimited.
/// [bitRate] Audio encoding bitrate in bits per second. Default is 128000.
///
/// Returns [Future<bool>] indicating success.
///
/// Example:
/// ```dart
/// final success = await recorder.startRecording(
///   duration: 60,
///   bitRate: 128000,
/// );
/// ```
Future<bool> startRecording({
  int? duration,
  int bitRate = 128000,
}) async {
  // Implementation / 实现
}
```

#### Inline Comments / 行内注释

Use bilingual comments for complex logic.

为复杂逻辑使用双语注释。

✅ **Good / 好的**:
```dart
// Pre-initialize recorder singleton to reduce launch time
// 预初始化录音器单例以减少启动时间
if (!_recorder.isInitialized) {
  await _recorder.initialize();
}

// Calculate encryption key from device ID + salt
// 从设备ID和盐值计算加密密钥
final key = _generateEncryptionKey(deviceId);
```

❌ **Bad / 不好的**:
```dart
await _recorder.initialize(); // What for? Why? / 为了什么？为什么？
final key = _generateKey(id);
```

---

## Python/FastAPI Standards / PythonFastAPI规范

### File Organization / 文件组织

```
backend/
├── main.py                       # Application entry / 应用入口
├── api/                          # API routes / API路由
│   └── v1/
│       ├── __init__.py
│       ├── capsules.py           # Capsule endpoints / 胶囊端点
│       ├── streaming.py          # WebSocket endpoints / WebSocket端点
│       └── context.py            # Context endpoints / 上下文端点
├── core/                         # Core functionality / 核心功能
│   ├── config.py                 # Configuration / 配置
│   ├── security.py               # Security / 安全
│   ├── logging.py                # Logging / 日志
│   └── exceptions.py             # Custom exceptions / 自定义异常
├── models/                       # Database models / 数据模型
│   ├── capsule.py
│   └── user.py
├── schemas/                      # Pydantic schemas / Pydantic模式
│   ├── capsule.py
│   └── user.py
├── services/                     # Business logic / 业务逻辑
│   ├── base_service.py
│   ├── stt/
│   │   ├── base_stt.py
│   │   └── volcengine_stt.py
│   └── llm/
│       ├── base_llm.py
│       └── deepseek_llm.py
└── database.py                   # Database connection / 数据库连接
```

### Naming Conventions / 命名规范

#### Files and Modules / 文件和模块

✅ **Good / 好的**:
```python
# file: api/v1/capsules.py
# class: CapsuleAPI
# function: create_capsule
```

❌ **Bad / 不好的**:
```python
# file: Capsules.py  # lowercase_with_underscores
# class: capsulesAPI  # PascalCase
# function: CreateCapsule  # snake_case
```

#### Variables / 变量

✅ **Good / 好的**:
```python
user_id = "uuid"
recording_duration = 120  # seconds / 秒
is_processing = True
```

❌ **Bad / 不好的**:
```python
userId = "uuid"  # snake_case required
recordingDuration = 120  # snake_case required
is_processing = true  # True (capital T) / 大写T
```

#### Constants / 常量

✅ **Good / 好的**:
```python
# config.py
MAX_RECORDING_DURATION = 300  # seconds / 秒
DEFAULT_BITRATE = 128000
API_BASE_URL = "https://api.echomemo.com"
```

❌ **Bad / 不好的**:
```python
maxRecordingDuration = 300  # UPPER_CASE required / 必须大写
api_base_url = "https://..."  # UPPER_CASE for constants / 常量大写
```

#### Classes / 类名

✅ **Good / 好的**:
```python
class AudioRecorderService:
    pass

class TranscriptionBlock:
    pass
```

❌ **Bad / 不好的**:
```python
class audioRecorderService:  # PascalCase required / 需要帕斯卡命名
class Audio_Recorder_Service:  # No underscores / 不要下划线
```

### Code Style / 代码风格

#### Formatting / 格式化

Use `black` with line length 100.

使用 `black`，行长100。

```bash
# Format all files / 格式化所有文件
black .

# Check formatting / 检查格式
black --check .
```

#### Imports / 导入

**Order / 顺序**:
1. Standard library / 标准库
2. Third-party / 第三方
3. Local application / 本地应用

✅ **Good / 好的**:
```python
import asyncio
from datetime import datetime
from typing import AsyncIterator

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from api.v1.schemas.capsule import CapsuleCreate
from core.config import settings
from services.stt.volcengine_stt import VolcengineSTTService
```

#### Type Hints / 类型提示

**Required / 必需**: All functions must have type hints.

所有函数必须有类型提示。

✅ **Good / 好的**:
```python
async def create_capsule(
    capsule_data: CapsuleCreate,
    db: AsyncSession,
) -> Capsule:
    """Create a new thought capsule. / 创建新的思想胶囊."""
    capsule = Capsule(**capsule_data.dict())
    db.add(capsule)
    await db.commit()
    await db.refresh(capsule)
    return capsule
```

❌ **Bad / 不好的**:
```python
async def create_capsule(capsule_data, db):  # Missing type hints / 缺少类型提示
    capsule = Capsule(**capsule_data.dict())
    db.add(capsule)
    await db.commit()
    return capsule
```

### Async Patterns / 异步模式

#### Always Use Async / 始终使用异步

All I/O operations must be async.

所有I/O操作必须异步。

✅ **Good / 好的**:
```python
@router.post("/v1/capsules")
async def create_capsule(
    capsule_data: CapsuleCreate,
    db: AsyncSession = Depends(get_db),
):
    # Async database operation / 异步数据库操作
    capsule = await create_capsule_async(capsule_data, db)
    return JSONResponse(
        status_code=201,
        content={"id": str(capsule.id)},
    )
```

❌ **Bad / 不好的**:
```python
@router.post("/v1/capsules")
async def create_capsule(capsule_data: CapsuleCreate):
    # Sync I/O in async function / 异步函数中的同步I/O - BAD
    capsule = db.add(Capsule(**capsule_data.dict()))  # Don't do this / 不要这样做
    return capsule
```

#### Error Handling / 错误处理

Use proper exception handling.

使用正确的异常处理。

✅ **Good / 好的**:
```python
@router.post("/v1/capsules")
async def create_capsule(
    capsule_data: CapsuleCreate,
    db: AsyncSession = Depends(get_db),
):
    try:
        capsule = await create_capsule_async(capsule_data, db)
    except DatabaseIntegrityError as e:
        logger.error(f"Database integrity error: {e}")
        raise HTTPException(
            status_code=400,
            detail="Invalid capsule data",
        )
    except Exception as e:
        logger.exception("Unexpected error creating capsule")
        raise HTTPException(
            status_code=500,
            detail="Internal server error",
        )

    return capsule
```

### Logging / 日志

#### Structured Logging / 结构化日志

Use bilingual structured logging.

使用双语结构化日志。

✅ **Good / 好的**:
```python
logger.info(
    "capsule_created",
    extra={
        "capsule_id": str(capsule.id),
        "user_id": str(capsule.user_id),
        "duration_seconds": capsule.duration_seconds,
        "zh_message": f"创建胶囊 #{capsule.id}",
    }
)
```

#### Log Levels / 日志级别

- **DEBUG**: Detailed debugging info / 详细调试信息
- **INFO**: General info / 一般信息
- **WARNING**: Warning messages / 警告消息
- **ERROR**: Error occurred / 发生错误
- **CRITICAL**: Serious error / 严重错误

✅ **Example / 示例**:
```python
logger.debug("Starting transcription process / 开始转译过程")
logger.info("Transcription completed successfully / 转译成功完成")
logger.warning("Transcription confidence low / 转译置信度低")
logger.error("Failed to transcribe audio / 转译音频失败")
logger.critical("Database connection lost / 数据库连接丢失")
```

### Docstrings / 文档字符串

All public functions must have bilingual docstrings.

所有公开函数必须有双语文档字符串。

✅ **Required / 必需**:
```python
async def process_memo(
    memo_id: int,
    audio_path: str,
) -> dict:
    """
    Process audio memo through STT and LLM pipeline.
    处理音频备忘录，通过STT和LLM流程。

    Args:
        memo_id (int): Memo database ID / 备忘录数据库ID
        audio_path (str): Path to audio file / 音频文件路径

    Returns:
        dict: Processing result containing: / 处理结果包含：
            - transcription (str): Transcribed text / 转写文本
            - summary (str): AI-generated summary / AI生成的摘要
            - emotion (str): Detected emotion / 检测到的情绪

    Raises:
        STTException: If transcription fails / 如果转译失败
        LLMException: If LLM analysis fails / 如果LLM分析失败

    Example:
        ```python
        result = await process_memo(memo_id=123, audio_path="/tmp/audio.m4a")
        print(result["transcription"])
        ```
    """
    pass
```

---

## Git Workflow / Git工作流

### Branch Naming / 分支命名

**Pattern / 模式**: `<type>/<short-description>`

✅ **Good / 好的**:
```bash
feature/phase-1-task-1.1.2
feature/audio-recorder-preinit
bugfix/stt-latency-issue
hotfix/security-patch-001
refactor/database-connection
release/v1.0.0
docs/update-readme
test/add-recording-tests
```

❌ **Bad / 不好的**:
```bash
task-1.1.2                    # Missing type / 缺少类型
audioRecorderPreinit          # Use kebab-case / 使用短横线命名
new-feature                   # Too vague / 太模糊
fix                           # Not descriptive / 不够描述性
```

### Commit Messages / 提交消息

**Format / 格式**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types / 类型**:
- `feat`: New feature / 新功能
- `fix`: Bug fix / 修复bug
- `refactor`: Code refactoring / 代码重构
- `docs`: Documentation / 文档
- `test`: Tests / 测试
- `chore`: Maintenance / 维护
- `perf`: Performance / 性能
- `style`: Style changes / 风格变更
- `security`: Security fix / 安全修复

✅ **Good / 好的**:
```bash
feat(recorder): implement pre-initialized audio recorder

Pre-initialize recorder singleton to reduce app launch time.
- Created singleton pattern in AudioRecorderService
- Added initialize() call in main.dart
- Reduced launch time from 3.2s to 1.8s

实现录音器预初始化以减少应用启动时间。
- 在AudioRecorderService中创建单例模式
- 在main.dart中添加initialize()调用
- 启动时间从3.2秒减少到1.8秒

Closes #123
```

❌ **Bad / 不好的**:
```bash
update code           # Too vague / 太模糊
fix bug              # Which bug? / 哪个bug？
added new feature    # Don't use past tense / 不要用过去时
FEATURE: Recorder    # Don't use caps / 不要大写
```

### Pull Request Guidelines / PR指南

#### PR Title / PR标题

Use same format as commit messages.

使用与提交消息相同的格式。

✅ **Good / 好的**:
```
feat(recorder): Implement pre-initialized audio recorder
feat(转写): 实现录音器预初始化
```

#### PR Description / PR描述

```markdown
## Summary / 概述
Implements pre-initialized audio recorder singleton to reduce app launch time from 3.2s to 1.8s.

实现录音器预初始化单例，将应用启动时间从3.2秒减少到1.8秒。

## Changes / 变更
- [x] Create singleton pattern in AudioRecorderService
- [x] Add initialize() call in main.dart
- [x] Add unit tests for singleton behavior
- [x] Update documentation

## Testing / 测试
- [x] Unit tests pass
- [x] Manual testing on iOS simulator
- [x] Manual testing on Android emulator
- [x] Launch time measured: 1.8s average (10 runs)

## Related Issues / 相关问题
Closes #123
Related to #456

## Screenshots / 截图 (if applicable / 如适用)
[Attach screenshots / 附加截图]

## Checklist / 检查清单
- [x] Code follows style guidelines
- [x] Self-review completed
- [x] Added comments to complex code
- [x] Documentation updated
- [x] No new warnings
- [x] Tests added/updated
- [x] All tests pass
```

### Git Commands / Git命令

#### Starting Work / 开始工作

```bash
# 1. Update main branch / 更新主分支
git checkout main
git pull origin main

# 2. Create feature branch / 创建功能分支
git checkout -b feature/phase-1-task-1.1.2

# 3. Work and commit / 工作并提交
git add .
git commit -m "feat(recorder): implement pre-initialization"

# 4. Push frequently / 频繁推送
git push -u origin feature/phase-1-task-1.1.2
```

#### Finishing Work / 完成工作

```bash
# 1. Ensure everything is pushed / 确保一切已推送
git push

# 2. Create PR via GitHub / 通过GitHub创建PR
gh pr create --title "feat(recorder): ..." --body "..."

# 3. After merge, delete branch / 合并后删除分支
git checkout main
git pull origin main
git branch -d feature/phase-1-task-1.1.2
```

---

## Testing Standards / 测试规范

### Flutter Tests / Flutter测试

#### Unit Tests / 单元测试

**Target / 目标**: ≥70% coverage

✅ **Example / 示例**:
```dart
// test/core/services/audio_recorder_service_test.dart

void main() {
  group('AudioRecorderService', () {
    late AudioRecorderService service;

    setUp(() {
      service = AudioRecorderService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should initialize recorder on creation / 应该在创建时初始化录音器', () {
      expect(service.isInitialized, true);
    });

    test('should start recording successfully / 应该成功开始录音', () async {
      await service.startRecording();
      expect(service.isRecording, true);
    });

    test('should throw exception if already recording / 如果正在录音应该抛出异常', () async {
      await service.startRecording();

      expect(
        () => service.startRecording(),
        throwsA(isA<RecorderException>()),
      );
    });
  });
}
```

#### Widget Tests / 组件测试

✅ **Example / 示例**:
```dart
// test/features/instant_capture/widgets/memo_card_test.dart

void main() {
  testWidgets('MemoCard displays transcription / MemoCard显示转写文本', (tester) async {
    final memo = Memo(
      id: '123',
      transcription: 'Test transcription',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MemoCard(memo: memo),
      ),
    );

    expect(find.text('Test transcription'), findsOneWidget);
  });

  testWidgets('MemoCard shows loading indicator when processing / 处理中时显示加载指示器', (tester) async {
    final memo = Memo(
      id: '123',
      status: 'processing',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MemoCard(memo: memo),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Python Tests / Python测试

#### Unit Tests / 单元测试

✅ **Example / 示例**:
```python
# tests/services/stt/test_volcengine_stt.py

import pytest
from services.stt.volcengine_stt import VolcengineSTTService
from core.exceptions import STTException

@pytest.mark.asyncio
async def test_transcribe_success():
    """Test successful transcription / 测试成功转译."""
    service = VolcengineSTTService(config=test_config)

    result = await service.transcribe("test_audio.m4a")

    assert result == "Hello world"
    assert len(result) > 0

@pytest.mark.asyncio
async def test_transcribe_file_not_found():
    """Test transcription with missing file / 测试文件缺失的转译."""
    service = VolcengineSTTService(config=test_config)

    with pytest.raises(STTException) as exc_info:
        await service.transcribe("nonexistent.m4a")

    assert "file not found" in str(exc_info.value).lower()
```

#### Integration Tests / 集成测试

✅ **Example / 示例**:
```python
# tests/api/integration/test_capsules_flow.py

import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_full_capsule_flow():
    """Test complete capsule creation and processing / 测试完整的胶囊创建和处理流程."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        # 1. Create capsule / 创建胶囊
        response = await client.post(
            "/v1/capsules",
            files={"audio": open("test_audio.m4a", "rb")},
        )
        assert response.status_code == 201
        capsule_id = response.json()["id"]

        # 2. Wait for processing / 等待处理
        await asyncio.sleep(5)

        # 3. Get capsule details / 获取胶囊详情
        response = await client.get(f"/v1/capsules/{capsule_id}")
        assert response.status_code == 200
        assert response.json()["transcription_status"] == "completed"
        assert response.json()["transcription"] is not None
```

### Running Tests / 运行测试

#### Flutter / Flutter

```bash
# Run all tests / 运行所有测试
flutter test

# Run with coverage / 运行并生成覆盖率
flutter test --coverage

# View coverage report / 查看覆盖率报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific test file / 运行特定测试文件
flutter test test/core/services/audio_recorder_service_test.dart
```

#### Python / Python

```bash
# Run all tests / 运行所有测试
pytest

# Run with coverage / 运行并生成覆盖率
pytest --cov=backend --cov-report=html

# Run specific test file / 运行特定测试文件
pytest tests/services/stt/test_volcengine_stt.py

# Run with verbose output / 详细输出
pytest -v

# Stop on first failure / 首次失败时停止
pytest -x
```

---

## Code Review Checklist / 代码审查清单

### Before Submitting PR / 提交PR前

- [ ] **Code compiles without errors or warnings / 代码编译无错误或警告**
  - Flutter: `flutter analyze` passes / 通过
  - Python: `pylint backend/` score ≥ 8.0

- [ ] **All tests pass / 所有测试通过**
  - Flutter: `flutter test` passes / 通过
  - Python: `pytest` passes / 通过

- [ ] **Code follows style guidelines / 代码遵循风格指南**
  - Flutter: `dart format .` applied / 已应用
  - Python: `black .` applied / 已应用

- [ ] **No hardcoded secrets / 无硬编码密钥**
  - No API keys in code / 代码中无API密钥
  - Use environment variables / 使用环境变量

- [ ] **Public APIs documented / 公开API已文档化**
  - Dart: All public classes/functions have doc comments / 所有公开类/函数有文档注释
  - Python: All public functions have docstrings / 所有公开函数有文档字符串

- [ ] **Error handling implemented / 已实现错误处理**
  - Try-catch blocks where needed / 在需要的地方使用try-catch
  - User-friendly error messages / 用户友好的错误消息

- [ ] **Performance considered / 已考虑性能**
  - No obvious performance issues / 无明显性能问题
  - Expensive operations are async / 昂贵的操作是异步的

- [ ] **Bilingual comments / 双语注释**
  - Complex logic has Chinese + English comments / 复杂逻辑有中英文注释

### During Review / 审查期间

- [ ] **Logic correctness / 逻辑正确性**
  - Does the code do what it's supposed to? / 代码是否做了它应该做的？
  - Edge cases handled? / 是否处理了边缘情况？

- [ ] **Security / 安全性**
  - User data encrypted? / 用户数据是否加密？
  - No SQL injection vectors? / 无SQL注入风险？
  - No XSS vulnerabilities? / 无XSS漏洞？

- [ ] **Performance / 性能**
  - Are there obvious performance bottlenecks? / 有明显的性能瓶颈吗？
  - Database queries optimized? / 数据库查询优化了吗？

- [ ] **Maintainability / 可维护性**
  - Code is readable? / 代码可读吗？
  - Naming is clear? / 命名清晰吗？
  - Not over-engineered? / 没有过度设计？

- [ ] **Testing / 测试**
  - Tests cover the new code? / 测试覆盖了新代码吗？
  - Tests are meaningful? / 测试有意义吗？

---

## Performance Guidelines / 性能指南

### Flutter Performance / Flutter性能

#### Build Optimization / 构建优化

✅ **Use const constructors / 使用const构造函数**:
```dart
const SizedBox(height: 16.0)
const EdgeInsets.all(16.0)
```

✅ **Lazy loading / 延迟加载**:
```dart
import 'screens/settings_screen.dart' deferred as settings;

// Load when needed / 需要时加载
await settings.loadLibrary();
Navigator.push(context, settings.SettingsScreen());
```

✅ **Repaint boundaries / 重绘边界**:
```dart
RepaintBoundary(
  child: WaveformVisualizer(),  // Only this repaints / 只有这个重绘
)
```

#### List Performance / 列表性能

✅ **Use ListView.builder for long lists / 长列表使用ListView.builder**:
```dart
ListView.builder(
  itemCount: memos.length,
  itemBuilder: (context, index) {
    return MemoCard(memo: memos[index]);
  },
)
```

❌ **Don't use ListView() with many children / 不要用ListView()包含多个子项**:
```dart
ListView(
  children: [
    MemoCard(memo: memos[0]),
    MemoCard(memo: memos[1]),
    // ... 1000 items - BAD / 不好
  ],
)
```

#### Async Performance / 异步性能

✅ **Use Isolates for CPU-intensive work / CPU密集型工作使用Isolate**:
```dart
final result = await compute(
  heavyComputation,
  data,
);
```

### Python Performance / Python性能

#### Database Queries / 数据库查询

✅ **Select only needed columns / 只选择需要的列**:
```python
# Good / 好
stmt = select(
    ThoughtCapsule.id,
    ThoughtCapsule.created_at,
    ThoughtCapsule.transcription,
)

# Bad / 差
stmt = select(ThoughtCapsule)  # Selects all columns / 选择所有列
```

✅ **Use eager loading / 使用预加载**:
```python
# Good / 好 - single query with join / 单查询加连接
stmt = select(ThoughtCapsule).options(
    selectinload(ThoughtCapsule.transcription_blocks)
)

# Bad / 差 - N+1 queries / N+1查询
capsules = await session.execute(select(ThoughtCapsule))
for capsule in capsules:
    blocks = capsule.transcription_blocks  # Separate query for each / 每个单独查询
```

#### Async Best Practices / 异步最佳实践

✅ **Use asyncio.gather for concurrent operations / 并发操作使用asyncio.gather**:
```python
# Run concurrently / 并发运行
transcription, summary = await asyncio.gather(
    stt_service.transcribe(audio_path),
    llm_service.analyze(transcription),
)
```

❌ **Don't block event loop / 不要阻塞事件循环**:
```python
# Bad / 差 - blocks event loop / 阻塞事件循环
result = blocking_function()

# Good / 好 - run in thread pool / 在线程池运行
result = await asyncio.to_thread(blocking_function)
```

---

## Security Standards / 安全规范

### Data Encryption / 数据加密

#### Flutter Encryption / Flutter加密

✅ **Required / 必需**:
```dart
// All audio files must be encrypted / 所有音频文件必须加密
final encryptedData = await encryptionService.encrypt(audioBytes);

// Store securely / 安全存储
final file = await secureStorage.writeFile(
  'capsule_$id.enc',
  encryptedData,
);
```

#### Backend Encryption / 后端加密

✅ **Never store plaintext audio / 永不存储明文音频**:
```python
# Reject unencrypted uploads / 拒绝未加密的上传
if not is_encrypted(audio_file):
    raise HTTPException(
        status_code=400,
        detail="Audio must be encrypted",
    )
```

### API Key Management / API密钥管理

#### Rules / 规则

1. **Never commit API keys / 永不提交API密钥**
2. **Use environment variables / 使用环境变量**
3. **Create .env.example templates / 创建.env.example模板**

✅ **Correct / 正确**:
```python
# backend/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    llm_api_key: str
    stt_access_key: str
    stt_secret_key: str

    class Config:
        env_file = ".env"

settings = Settings()
```

```bash
# .env
LLM_API_KEY=sk-xxx
STT_ACCESS_KEY=xxx
STT_SECRET_KEY=xxx
```

```bash
# .env.example
LLM_API_KEY=your_deepseek_api_key_here
STT_ACCESS_KEY=your_volcengine_access_key_here
STT_SECRET_KEY=your_volcengine_secret_key_here
```

❌ **Never / 永远不要**:
```python
# Hardcoded keys - NEVER DO THIS / 硬编码密钥 - 永远不要这样做
API_KEY = "sk-c1516d24062543139ed465931804262c"
```

### Input Validation / 输入验证

#### Backend Validation / 后端验证

✅ **Always validate input / 始终验证输入**:
```python
from pydantic import BaseModel, Field, validator

class CapsuleCreate(BaseModel):
    audio_path: str = Field(..., min_length=1, max_length=255)
    duration_seconds: int = Field(..., ge=1, le=3600)

    @validator('audio_path')
    def validate_audio_path(cls, v):
        if not v.endswith(('.m4a', '.mp3', '.wav')):
            raise ValueError('Invalid audio format')
        return v
```

### SQL Injection Prevention / SQL注入预防

✅ **Use ORM / 使用ORM**:
```python
# Safe / 安全 - SQLAlchemy ORM
capsule = await session.get(ThoughtCapsule, capsule_id)

# Dangerous / 危险 - SQL injection risk / SQL注入风险
# Don't do this / 不要这样做
query = f"SELECT * FROM capsules WHERE id = '{user_input}'"
```

---

## Documentation Standards / 文档规范

### Code Comments / 代码注释

#### When to Comment / 何时注释

✅ **Comment / 添加注释**:
- Complex algorithms / 复杂算法
- Business logic decisions / 业务逻辑决策
- Workarounds for bugs / bug的变通方法
- Performance optimizations / 性能优化

❌ **Don't comment / 不要注释**:
- Obvious code / 显而易见的代码
- Outdated information / 过时的信息
- Every line of code / 每行代码

✅ **Good example / 好的示例**:
```dart
// BRIN index is more efficient for time-series data
// BRIN索引对时序数据更高效
CREATE INDEX idx_capsules_created_brin
ON thought_capsules USING BRIN (created_at);
```

❌ **Bad example / 不好的示例**:
```dart
// Increment counter / 增加计数器
counter++;  // Obvious / 显而易见
```

### README Files / README文件

Every major directory should have a README.

每个主要目录应该有README。

✅ **Structure / 结构**:
```markdown
# Directory Purpose / 目录用途

Brief description of what this directory does.
简要描述此目录的用途。

## Key Files / 关键文件

- `file.dart`: Description / 描述
- `another.py`: Description / 描述

## Usage / 使用方法

```bash
# Example command / 示例命令
python script.py
```

## Notes / 注意事项

- Important note 1 / 重要提示1
- Important note 2 / 重要提示2
```

---

## Development Workflow / 开发工作流

### Daily Workflow / 每日工作流

#### Start of Day / 一天开始

1. **Pull latest code / 拉取最新代码**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Check progress tracker / 检查进度追踪器**
   - Open `docs/tracking/progress-tracker.md`
   - Find 🚧 "In Progress" task / 找到"进行中"任务

3. **Review decision log / 审查决策日志**
   - Check `docs/tracking/decision-log.md`
   - Be aware of recent decisions / 了解最近的决策

#### During Work / 工作中

1. **Follow task breakdown / 遵循任务分解**
   - Open specific phase plan / 打开特定阶段计划
   - Follow code examples / 遵循代码示例

2. **Commit frequently / 频繁提交**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   git push
   ```

3. **Run tests / 运行测试**
   ```bash
   # Flutter / Flutter
   flutter test

   # Python / Python
   pytest
   ```

#### End of Day / 一天结束

1. **Update progress tracker / 更新进度追踪器**
   - Mark completed tasks as ✅
   - Add entry to Daily Progress Log / 添加到每日进度日志

2. **Update task status / 更新任务状态**
   - Change 🚧 to ✅ for completed tasks / 完成的任务从🚧改为✅
   - Change 📋 to 🚧 for next task / 下一个任务从📋改为🚧

3. **Commit documentation / 提交文档**
   ```bash
   git add docs/
   git commit -m "docs: update progress"
   git push
   ```

### Resuming After Absence / 缺席后恢复

1. **Read progress tracker / 阅读进度追踪器**
   - "Current Status" section / "当前状态"部分
   - "Daily Progress Log" / "每日进度日志"

2. **Read decision log / 阅读决策日志**
   - Recent decisions / 最近的决策

3. **Find next task / 找到下一个任务**
   - In phase plan / 在阶段计划中
   - Look for unchecked ☐ tasks / 查找未选中的☐任务

4. **Resume work / 恢复工作**
   - Follow code examples / 遵循代码示例
   - Update progress as you go / 随时更新进度

---

## Quick Reference / 快速参考

### Before Committing / 提交前检查清单

```bash
# Flutter / Flutter
flutter analyze              # Must pass / 必须通过
flutter test                 # Must pass / 必须通过
dart format .                # Apply formatting / 应用格式化

# Python / Python
pylint backend/              # Score ≥ 8.0 / 分数≥8.0
pytest                       # Must pass / 必须通过
black .                      # Apply formatting / 应用格式化

# Git / Git
git add .
git commit -m "type(scope): description"
git push
```

### Code Quality Gates / 代码质量门禁

- ✅ All tests pass / 所有测试通过
- ✅ No linting errors / 无代码检查错误
- ✅ Code formatted / 代码已格式化
- ✅ No hardcoded secrets / 无硬编码密钥
- ✅ Documentation updated / 文档已更新
- ✅ Bilingual comments / 双语注释

---

## Related Documents / 相关文档

- [Quick Start Guide](./QUICKSTART.md)
- [Phase 1 Plan](./phases/phase-01-container.md)
- [System Design](./architecture/system-design.md)
- [Progress Tracker](./tracking/progress-tracker.md)
- [Decision Log](./tracking/decision-log.md)

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
**Next Review**: Monthly or when major patterns change
**Maintained By**: EchoMemo Development Team

**For questions / 如有疑问**: See [Documentation README](./README.md)
