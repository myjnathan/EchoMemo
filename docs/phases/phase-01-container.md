# Phase 1: The Container (容器) - Execution Plan

**Status**: 🚀 In Development / 开发中
**Timeline**: 4-6 weeks / 4-6周
**Priority**: Critical / 关键
**Last Updated**: 2025-02-15

---

## 📋 Table of Contents / 目录

1. [Phase Overview / 阶段概览](#phase-overview)
2. [Success Metrics / 成功指标](#success-metrics)
3. [Technical Requirements / 技术需求](#technical-requirements)
4. [Task Breakdown / 任务分解](#task-breakdown)
5. [Implementation Sequence / 实施顺序](#implementation-sequence)
6. [Resumption Protocol / 恢复协议](#resumption-protocol)

---

## Phase Overview / 阶段概览

### Core Philosophy / 核心理念

**"Existence through Capture" / "通过捕获实现存在"**

Phase 1 focuses on building absolute trust through frictionless voice capture. The goal is to compress the time between thought impulse and recording to ≤1.5 seconds, achieving 90%+ thought capture conversion rate.

第一阶段专注于通过无摩擦的语音捕获建立绝对信任。目标是将思想冲动到录制之间的时间压缩到≤1.5秒，实现90%+的思想捕获转化率。

### Key Deliverables / 关键交付物

1. ⚡ **Instant Capture System** / **极速捕获系统**
   - App launch to recording in ≤1.5s
   - No buttons, just open-and-record
   - 应用启动到录制≤1.5秒
   - 无需按钮，打开即录

2. 🎤 **Streaming Transcription** / **流式转译**
   - Real-time voice-to-text display
   - Waveform visualization synchronized with speech
   - 实时语音到文字显示
   - 与语音同步的波形可视化

3. 📅 **Timeline Stream View** / **时间流视图**
   - Chronological "thought capsule" display
   - Context-aware (time, location, activity)
   - 按时间顺序的"思维胶囊"显示
   - 上下文感知（时间、位置、活动）

### Non-Negotiable Principles / 不可妥协的原则

1. **Speed is Everything / 速度即一切**: 1.5s or fail / 1.5秒或失败
2. **Zero Friction / 零摩擦**: No categories, no titles, no tags / 无分类、无标题、无标签
3. **Privacy First / 隐私优先**: Local-first, encrypted storage / 本地优先，加密存储
4. **Simplicity / 简洁性**: Single-purpose app / 单一用途应用

---

## Success Metrics / 成功指标

### Quantitative Metrics / 定量指标

| Metric / 指标 | Target / 目标 | Current / 当前 | Status / 状态 |
|---------------|---------------|----------------|---------------|
| **Capture Conversion Rate** / 捕获转化率 | ≥90% | - | 📋 Pending |
| **Launch-to-Record Time** / 启动到录制时间 | ≤1.5s | ~3s | 🚧 In Progress |
| **Average Recording Duration** / 平均录制时长 | 60-180s | - | 📋 Pending |
| **Weekly Active Users Recording 5+** / 周活跃用户记录5+ | ≥60% | - | 📋 Pending |
| **App Crash Rate** / 应用崩溃率 | <0.1% | - | 📋 Pending |

### Qualitative Metrics / 定性指标

- ✅ User feels "safe" to express anything / 用户感到可以安全地表达任何内容
- ✅ Recording feels as natural as breathing / 录制感觉像呼吸一样自然
- ✅ Zero hesitation before recording / 录制前零犹豫
- ✅ Trust that nothing will be lost / 信任不会丢失任何内容

---

## Technical Requirements / 技术需求

### Frontend Requirements / 前端需求

#### Flutter Performance Optimization

```dart
// Target performance metrics
class PerformanceTargets {
  static const double coldStartToRecording = 1.5; // seconds
  static const double warmStartToRecording = 0.5; // seconds
  static const int transcriptionLatency = 300; // ms
  static const double waveformUpdateRate = 60; // FPS
}
```

**Key optimizations needed / 需要的关键优化**:

1. **Lazy Loading / 延迟加载**:
   - Defer non-critical widgets / 延迟非关键小部件
   - Use `const` constructors aggressively / 积极使用`const`构造函数

2. **Background Initialization / 后台初始化**:
   - Pre-initialize audio recorder / 预初始化音频录制器
   - Warm up STT service connection / 预热STT服务连接
   - Cache API authentication token / 缓存API认证令牌

3. **State Management Optimization / 状态管理优化**:
   - Use `ChangeNotifier` judiciously / 明智地使用`ChangeNotifier`
   - Implement selective rebuilds / 实施选择性重建

#### Real-Time Transcription Integration

```yaml
# pubspec.yaml additions needed:
dependencies:
  flutter_sound: ^9.0.0  # Real-time audio streaming
  web_socket_channel: ^2.4.0  # For streaming STT
  isolate: ^2.0.0  # Background processing
```

#### Architecture Pattern

```dart
// Recommended architecture for Phase 1
lib/
├── main.dart                    # App entry point
├── core/
│   ├── services/
│   │   ├── audio_recorder.dart      # Audio recording service
│   │   ├── transcription_stream.dart # Real-time transcription
│   │   └── storage_service.dart     # Local encrypted storage
│   ├── models/
│   │   ├── thought_capsule.dart     # Core data model
│   │   └── transcription_block.dart  # Streaming text blocks
│   └── constants/
│       └── performance_targets.dart # Performance constants
├── features/
│   ├── instant_capture/
│   │   ├── widgets/
│   │   │   ├── recording_screen.dart    # Main recording UI
│   │   │   ├── waveform_visualizer.dart  # Audio waveform
│   │   │   └── streaming_text.dart      # Real-time transcription
│   │   └── controllers/
│   │       └── capture_controller.dart  # Recording logic
│   └── timeline_stream/
│       ├── widgets/
│       │   ├── capsule_list.dart        # Timeline list
│       │   ├── capsule_card.dart        # Individual capsule
│       │   └── context_indicators.dart   # Time/location icons
│       └── controllers/
│           └── timeline_controller.dart # Timeline logic
└── shared/
    ├── widgets/
    │   └── optimized_widgets.dart   # Performance-optimized widgets
    └── utils/
        └── performance_monitor.dart # Performance tracking
```

### Backend Requirements / 后端需求

#### Streaming STT Endpoint

```python
# New FastAPI endpoint needed
@router.post("/v1/transcribe/stream")
async def stream_transcription(
    audio_chunk: UploadFile,
    request_id: str,
    session_id: str
):
    """
    Streaming transcription endpoint
    流式转译端点

    Requirements:
    - <300ms latency per chunk
    - Supports partial results
    - Maintains session context
    """
```

#### Context Capture Service

```python
# New service needed
class ContextCaptureService:
    """
    Captures contextual metadata for each recording
    为每次录制捕获上下文元数据
    """

    async def capture_context(self) -> ContextMetadata:
        return ContextMetadata(
            timestamp=datetime.now(),
            geolocation=await get_location(),
            activity=await detect_activity(),
            weather=await get_weather(),
            device_info=get_device_info()
        )
```

#### Database Schema Updates

```sql
-- New tables needed for Phase 1
CREATE TABLE thought_capsules (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    audio_path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_seconds INTEGER,
    file_size_bytes INTEGER,

    -- Context metadata
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_name VARCHAR(255),
    activity_type VARCHAR(50),  -- walking, sitting, driving, etc.
    weather_condition VARCHAR(50),

    -- Status
    transcription_status VARCHAR(20) DEFAULT 'processing', -- processing, completed, failed
    has_transcription BOOLEAN DEFAULT FALSE,

    INDEX idx_user_created (user_id, created_at DESC),
    INDEX idx_transcription_status (transcription_status)
);

CREATE TABLE transcription_blocks (
    id UUID PRIMARY KEY,
    capsule_id UUID NOT NULL REFERENCES thought_capsules(id) ON DELETE CASCADE,
    block_order INTEGER NOT NULL,
    text TEXT NOT NULL,
    confidence DECIMAL(4, 3),
    is_final BOOLEAN DEFAULT FALSE,  -- True when STT confirms this block
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_capsule_order (capsule_id, block_order)
);

CREATE TABLE capsule_context (
    id UUID PRIMARY KEY,
    capsule_id UUID NOT NULL REFERENCES thought_capsules(id) ON DELETE CASCADE,
    context_type VARCHAR(50) NOT NULL,  -- location, weather, activity, etc.
    context_data JSONB NOT NULL,
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_capsule_context (capsule_id, context_type)
);
```

---

## Task Breakdown / 任务分解

### Epic 1: Instant Capture System / 极速捕获系统

**Story Points**: 21
**Target Completion**: Week 1-2 / 目标完成：第1-2周

#### Task 1.1: App Launch Optimization / 应用启动优化

**File**: `frontend/lib/main.dart`
**Priority**: P0 (Critical)
**Estimated Time**: 3-5 days

**Subtasks / 子任务**:

- [ ] **1.1.1** Implement deferred component loading
  - **File**: `frontend/lib/main.dart`
  - **Action**: Move non-essential imports to lazy loading
  - **Code**:
    ```dart
    // Before (slow):
    import 'screens/home_screen.dart';
    import 'screens/settings_screen.dart';
    import 'screens/profile_screen.dart';

    // After (fast):
    import 'screens/instant_capture_screen.dart' sync deferred; // Load immediately
    import 'screens/settings_screen.dart' deferred; // Load later
    ```
  - **Acceptance Criteria**: Initial app load <500ms

- [ ] **1.1.2** Pre-initialize audio recorder in background
  - **File**: `frontend/lib/core/services/audio_recorder.dart`
  - **Action**: Create singleton that initializes on app start
  - **Code**:
    ```dart
    class AudioRecorderService {
      static final AudioRecorderService _instance = AudioRecorderService._internal();
      factory AudioRecorderService() => _instance;

      AudioRecorderService._internal() {
        // Initialize recorder in background
        _initializeRecorder();
      }

      Future<void> _initializeRecorder() async {
        // Pre-warm the recorder
        await recorder.openRecorder();
      }
    }
    ```
  - **Acceptance Criteria**: Recorder ready <100ms after app launch

- [ ] **1.1.3** Implement splashless launch
  - **File**: `frontend/lib/main.dart`
  - **Action**: Remove splash screen, go directly to recording
  - **Code**:
    ```dart
    // Remove native splash screen
    // In main.dart:
    void main() {
      runApp(const EchoMemoApp());
    }

    class EchoMemoApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: InstantCaptureScreen(), // Direct to capture
          debugShowCheckedModeBanner: false,
        );
      }
    }
    ```
  - **Acceptance Criteria**: No splash screen delay

**Test Cases / 测试用例**:

```dart
// test/features/instant_capture/app_launch_test.dart
void main() {
  testWidgets('App launches to recording screen in <1.5s', (tester) async {
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(EchoMemoApp());
    await tester.pumpAndSettle();

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1500));
  });
}
```

**Next Task After Interruption / 中断后的下一个任务**: Task 1.2

---

#### Task 1.2: One-Tap Recording Interface / 一键录制界面

**File**: `frontend/lib/features/instant_capture/widgets/recording_screen.dart`
**Priority**: P0 (Critical)
**Estimated Time**: 2-3 days
**Depends On**: Task 1.1

**Subtasks / 子任务**:

- [ ] **1.2.1** Design minimal recording UI
  - **File**: `frontend/lib/features/instant_capture/widgets/recording_screen.dart`
  - **Requirements**:
    - Single large microphone button
    - No labels, no menus, no distractions
    - Waveform visualization background
  - **Code**:
    ```dart
    class RecordingScreen extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GestureDetector(
              onTap: () => _startRecording(),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.red,
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.mic,
                  size: 120,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      }
    }
    ```
  - **Acceptance Criteria**: Only 1 interactive element on screen

- [ ] **1.2.2** Implement haptic feedback on tap
  - **File**: `frontend/lib/features/instant_capture/widgets/recording_screen.dart`
  - **Code**:
    ```dart
    import 'package:haptic_feedback/haptic_feedback.dart';

    Future<void> _startRecording() async {
      await HapticFeedback.heavyImpact();
      await audioRecorder.start();
    }
    ```
  - **Acceptance Criteria**: User feels tactile confirmation

- [ ] **1.2.3** Add stop recording gesture
  - **File**: `frontend/lib/features/instant_capture/widgets/recording_screen.dart`
  - **Requirements**:
    - Tap again to stop
    - Visual indicator change (pulsing effect)
  - **Code**:
    ```dart
    bool _isRecording = false;

    Widget buildRecordingButton() {
      return GestureDetector(
        onTap: _toggleRecording,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    spreadRadius: 20,
                    blurRadius: 40,
                  ),
                ]
              : [],
          ),
          child: Icon(_isRecording ? Icons.stop : Icons.mic),
        ),
      );
    }
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 1.3

---

#### Task 1.3: Background Transcription Service / 后台转译服务

**File**: `frontend/lib/core/services/transcription_stream.dart`
**Priority**: P0 (Critical)
**Estimated Time**: 4-5 days
**Depends On**: Task 1.2

**Subtasks / 子任务**:

- [ ] **1.3.1** Implement WebSocket connection for streaming
  - **File**: `frontend/lib/core/services/transcription_stream.dart`
  - **Code**:
    ```dart
    class TranscriptionStreamService {
      late WebSocketChannel _channel;
      final StreamController<String> _transcriptionController = StreamController.broadcast();

      Future<void> connect(String sessionId) async {
        final wsUrl = Uri.parse('${ApiService.baseUrl}/v1/transcribe/stream?session_id=$sessionId');
        _channel = WebSocketChannel.connect(wsUrl);

        _channel.stream.listen(
          (data) {
            final response = jsonDecode(data);
            _transcriptionController.add(response['text']);
          },
          onError: (error) => print('Stream error: $error'),
          onDone: () => print('Stream closed'),
        );
      }

      Stream<String> get transcriptionStream => _transcriptionController.stream;

      Future<void> sendAudioChunk(List<int> audioData) async {
        _channel.sink.add(audioData);
      }
    }
    ```
  - **Acceptance Criteria**: Latency <300ms per chunk

- [ ] **1.3.2** Implement audio chunking and streaming
  - **File**: `frontend/lib/core/services/audio_recorder.dart`
  - **Requirements**:
    - Chunk size: 512-1024 bytes
    - Send interval: 100ms
    - Overlap chunks by 10% to avoid gaps
  - **Code**:
    ```dart
    class AudioRecorderService {
      final int _chunkSize = 1024;
      final int _sendInterval = 100; // ms
      Timer? _sendTimer;

      void _startStreaming(AudioStreamer streamer) {
        _sendTimer = Timer.periodic(Duration(milliseconds: _sendInterval), (timer) async {
          final chunk = await streamer.getNextChunk(_chunkSize);
          if (chunk != null) {
            await transcriptionService.sendAudioChunk(chunk);
          }
        });
      }
    }
    ```

- [ ] **1.3.3** Handle partial vs final results
  - **File**: `frontend/lib/features/instant_capture/widgets/streaming_text.dart`
  - **Code**:
    ```dart
    class StreamingTextWidget extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return StreamBuilder<TranscriptionBlock>(
          stream: transcriptionService.transcriptionStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            final block = snapshot.data!;
            return Text(
              block.text,
              style: TextStyle(
                color: block.isFinal ? Colors.white : Colors.white70,
                decoration: block.isFinal ? null : TextDecoration.underline,
              ),
            );
          },
        );
      }
    }
    ```

**Test Cases / 测试用例**:

```dart
test('Streaming transcription updates in real-time', () async {
  final mockWebSocket = MockWebSocketChannel();
  when(mockWebSocket.stream).thenAnswer((_) => Stream.fromIterable([
    '{"text": "Hello", "is_final": false}',
    '{"text": "Hello world", "is_final": true}',
  ]));

  final service = TranscriptionStreamService();
  await service.connect('test-session');

  final texts = await service.transcriptionStream.take(2).toList();
  expect(texts[0], equals('Hello'));
  expect(texts[1], equals('Hello world'));
});
```

**Next Task After Interruption / 中断后的下一个任务**: Task 1.4

---

#### Task 1.4: Waveform Visualization / 波形可视化

**File**: `frontend/lib/features/instant_capture/widgets/waveform_visualizer.dart`
**Priority**: P1 (High)
**Estimated Time**: 3-4 days
**Depends On**: Task 1.2

**Subtasks / 子任务**:

- [ ] **1.4.1** Implement real-time audio amplitude extraction
  - **File**: `frontend/lib/core/services/audio_analyzer.dart`
  - **Code**:
    ```dart
    class AudioAnalyzer {
      Stream<double> analyzeAmplitude(Stream<Uint8List> audioStream) async* {
        await for (final chunk in audioStream) {
          final amplitude = _calculateAmplitude(chunk);
          yield amplitude;
        }
      }

      double _calculateAmplitude(Uint8List chunk) {
        int sum = 0;
        for (int i = 0; i < chunk.length; i += 2) {
          int sample = (chunk[i + 1] << 8) | chunk[i];
          sum += sample.abs();
        }
        return sum / (chunk.length / 2);
      }
    }
    ```

- [ ] **1.4.2** Create smooth waveform animation
  - **File**: `frontend/lib/features/instant_capture/widgets/waveform_visualizer.dart`
  - **Code**:
    ```dart
    class WaveformVisualizer extends StatefulWidget {
      @override
      _WaveformVisualizerState createState() => _WaveformVisualizerState();
    }

    class _WaveformVisualizerState extends State<WaveformVisualizer>
        with SingleTickerProviderStateMixin {
      late AnimationController _controller;
      final List<double> _amplitudes = [];

      @override
      void initState() {
        super.initState();
        _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 16), // 60 FPS
        )..addListener(_updateWaveform);
        _controller.repeat();
      }

      void _updateWaveform() {
        if (_amplitudes.length > 50) _amplitudes.removeAt(0);
        setState(() {});
      }

      @override
      Widget build(BuildContext context) {
        return CustomPaint(
          painter: WaveformPainter(_amplitudes),
          size: Size.infinite,
        );
      }
    }
    ```

- [ ] **1.4.3** Sync waveform with transcription highlighting
  - **File**: `frontend/lib/features/instant_capture/widgets/waveform_visualizer.dart`
  - **Requirements**:
    - Highlight waveform regions when words are finalized
    - Color intensity based on speech volume
    - Smooth transitions between highlighted regions

**Next Task After Interruption / 中断后的下一个任务**: Task 1.5

---

#### Task 1.5: Local Encrypted Storage / 本地加密存储

**File**: `frontend/lib/core/services/storage_service.dart`
**Priority**: P0 (Critical)
**Estimated Time**: 2-3 days
**Depends On**: None (can work in parallel)

**Subtasks / 子任务**:

- [ ] **1.5.1** Implement AES-256 encryption for audio files
  - **File**: `frontend/lib/core/services/encryption_service.dart`
  - **Code**:
    ```dart
    import 'package:encrypt/encrypt.dart' as encrypt;

    class EncryptionService {
      final encrypt.Key _key;
      final encrypt.IV _iv;

      EncryptionService(String password)
        : _key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32)),
          _iv = encrypt.IV.fromLength(16);

      Future<Uint8List> encryptFile(Uint8List data) async {
        final encrypter = encrypt.Encrypter(
          encrypt.AES(_key, mode: encrypt.AESMode.gcm),
        );
        final encrypted = encrypter.encryptBytes(data, iv: _iv);
        return Uint8List.fromList(encrypted.bytes);
      }

      Future<Uint8List> decryptFile(Uint8List> encryptedData) async {
        final encrypter = encrypt.Encrypter(
          encrypt.AES(_key, mode: encrypt.AESMode.gcm),
        );
        final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedData), iv: _iv);
        return Uint8List.fromList(decrypted);
      }
    }
    ```
  - **Acceptance Criteria**: Encryption overhead <50ms per file

- [ ] **1.5.2** Store audio files locally using path_provider
  - **File**: `frontend/lib/core/services/storage_service.dart`
  - **Code**:
    ```dart
    import 'package:path_provider/path_provider.dart';
    import 'package:uuid/uuid.dart';

    class StorageService {
      Future<String> saveAudioFile(Uint8List audioData) async {
        final directory = await getApplicationDocumentsDirectory();
        final capsuleId = Uuid().v4();
        final filePath = '${directory.path}/capsules/$capsuleId.m4a';

        final file = File(filePath);
        await file.writeAsBytes(audioData);

        return filePath;
      }
    }
    ```

- [ ] **1.5.3** Implement secure key storage using flutter_secure_storage
  - **File**: `frontend/lib/core/services/secure_key_service.dart`
  - **Code**:
    ```dart
    import 'package:flutter_secure_storage/flutter_secure_storage.dart';

    class SecureKeyService {
      final _storage = FlutterSecureStorage();

      Future<void> saveEncryptionKey(String key) async {
        await _storage.write(key: 'encryption_key', value: key);
      }

      Future<String?> getEncryptionKey() async {
        return await _storage.read(key: 'encryption_key');
      }

      Future<String> generateOrGetKey() async {
        String? key = await getEncryptionKey();
        if (key == null) {
          key = generateRandomKey();
          await saveEncryptionKey(key);
        }
        return key;
      }

      String generateRandomKey() {
        final random = Random.secure();
        final values = List<int>.generate(32, (i) => random.nextInt(256));
        return base64.encode(values);
      }
    }
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 2.1

---

### Epic 2: Timeline Stream View / 时间流视图

**Story Points**: 13
**Target Completion**: Week 3-4 / 目标完成：第3-4周

#### Task 2.1: Timeline List Component / 时间列表组件

**File**: `frontend/lib/features/timeline_stream/widgets/capsule_list.dart`
**Priority**: P0 (Critical)
**Estimated Time**: 3-4 days
**Depends On**: None

**Subtasks / 子任务**:

- [ ] **2.1.1** Implement reverse chronological list
  - **File**: `frontend/lib/features/timeline_stream/widgets/capsule_list.dart`
  - **Code**:
    ```dart
    class CapsuleList extends StatelessWidget {
      final List<ThoughtCapsule> capsules;

      @override
      Widget build(BuildContext context) {
        return ListView.builder(
          reverse: true, // Newest at bottom
          itemCount: capsules.length,
          itemBuilder: (context, index) {
            return CapsuleCard(capsule: capsules[index]);
          },
        );
      }
    }
    ```
  - **Acceptance Criteria**: Smooth scrolling with 1000+ items

- [ ] **2.1.2** Add time-based grouping
  - **File**: `frontend/lib/features/timeline_stream/widgets/capsule_list.dart`
  - **Requirements**:
    - Group by: Today, Yesterday, This Week, Earlier
    - Sticky headers for each group
  - **Code**:
    ```dart
    class TimelineGroupHeader extends StatelessWidget {
      final String label;

      @override
      Widget build(BuildContext context) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: _TimelineHeaderDelegate(label),
        );
      }
    }
    ```

- [ ] **2.1.3** Implement lazy loading with pagination
  - **File**: `frontend/lib/features/timeline_stream/controllers/timeline_controller.dart`
  - **Code**:
    ```dart
    class TimelineController extends ChangeNotifier {
      final int _pageSize = 20;
      List<ThoughtCapsule> _capsules = [];
      bool _hasMore = true;

      Future<void> loadMore() async {
        if (!_hasMore) return;

        final newCapsules = await apiService.getCapsules(
          offset: _capsules.length,
          limit: _pageSize,
        );

        if (newCapsules.length < _pageSize) _hasMore = false;
        _capsules.addAll(newCapsules);
        notifyListeners();
      }
    }
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 2.2

---

#### Task 2.2: Context Indicators / 上下文指示器

**File**: `frontend/lib/features/timeline_stream/widgets/context_indicators.dart`
**Priority**: P1 (High)
**Estimated Time**: 2-3 days
**Depends On**: Task 2.1

**Subtasks / 子任务**:

- [ ] **2.2.1** Implement location indicator
  - **File**: `frontend/lib/features/timeline_stream/widgets/context_indicators.dart`
  - **Code**:
    ```dart
    class LocationIndicator extends StatelessWidget {
      final String? locationName;

      @override
      Widget build(BuildContext context) {
        if (locationName == null) return SizedBox();

        return Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey),
            SizedBox(width: 4),
            Text(locationName!, style: TextStyle(fontSize: 12)),
          ],
        );
      }
    }
    ```

- [ ] **2.2.2** Implement activity type indicator
  - **File**: `frontend/lib/features/timeline_stream/widgets/context_indicators.dart`
  - **Code**:
    ```dart
    class ActivityIndicator extends StatelessWidget {
      final String activityType;

      @override
      Widget build(BuildContext context) {
        IconData icon;
        switch (activityType) {
          case 'walking': icon = Icons.directions_walk; break;
          case 'sitting': icon = Icons.event_seat; break;
          case 'driving': icon = Icons.directions_car; break;
          default: icon = Icons.help_outline;
        }

        return Icon(icon, size: 14, color: Colors.grey);
      }
    }
    ```

- [ ] **2.2.3** Implement time-of-day visual indicator
  - **File**: `frontend/lib/features/timeline_stream/widgets/context_indicators.dart`
  - **Requirements**:
    - Morning (6-12): Sun icon, warm colors
    - Afternoon (12-18): Sun high icon, bright colors
    - Evening (18-22): Moon icon, cool colors
    - Night (22-6): Stars icon, dark colors
  - **Code**:
    ```dart
    class TimeOfDayIndicator extends StatelessWidget {
      final DateTime timestamp;

      @override
      Widget build(BuildContext context) {
        final hour = timestamp.hour;
        IconData icon;
        Color color;

        if (hour >= 6 && hour < 12) {
          icon = Icons.wb_sunny;
          color = Colors.orange;
        } else if (hour >= 12 && hour < 18) {
          icon = Icons.wb_twighlight;
          color = Colors.yellow;
        } else if (hour >= 18 && hour < 22) {
          icon = Icons.bedtime;
          color = Colors.indigo;
        } else {
          icon = Icons.nights_stay;
          color = Colors.deepPurple;
        }

        return Icon(icon, size: 16, color: color);
      }
    }
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 2.3

---

#### Task 2.3: Capsule Card Design / 胶囊卡片设计

**File**: `frontend/lib/features/timeline_stream/widgets/capsule_card.dart`
**Priority**: P1 (High)
**Estimated Time**: 3-4 days
**Depends On**: Task 2.1, Task 2.2

**Subtasks / 子任务**:

- [ ] **2.3.1** Design minimal capsule card
  - **File**: `frontend/lib/features/timeline_stream/widgets/capsule_card.dart`
  - **Requirements**:
    - Show: Time, duration, first line of transcription
    - Expand to show full transcription
    - Tap to play audio
  - **Code**:
    ```dart
    class CapsuleCard extends StatelessWidget {
      final ThoughtCapsule capsule;

      @override
      Widget build(BuildContext context) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () => _playAudio(capsule),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TimeOfDayIndicator(timestamp: capsule.createdAt),
                      SizedBox(width: 8),
                      Text(_formatTime(capsule.createdAt)),
                      Spacer(),
                      Text(_formatDuration(capsule.duration)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    capsule.transcription ?? 'Processing...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    ```

- [ ] **2.3.2** Add swipe-to-reveal actions
  - **File**: `frontend/lib/features/timeline_stream/widgets/capsule_card.dart`
  - **Requirements**:
    - Swipe left: Delete
    - Swipe right: Share
    - Swipe up: Edit tags (Phase 2 feature, hide for now)
  - **Code**:
    ```dart
    class SwipeableCapsuleCard extends StatelessWidget {
      final ThoughtCapsule capsule;

      @override
      Widget build(BuildContext context) {
        return Dismissible(
          key: Key(capsule.id),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _shareCapsule(capsule);
            } else {
              _deleteCapsule(capsule);
            }
          },
          background: _buildSwipeBackground(),
          child: CapsuleCard(capsule: capsule),
        );
      }
    }
    ```

- [ ] **2.3.3** Implement contextual memory anchors
  - **File**: `frontend/lib/features/timeline_stream/widgets/context_indicators.dart`
  - **Requirements**:
    - Show small icon for location, activity, weather
    - Only show if different from previous capsule
    - Hover to reveal full details

**Next Task After Interruption / 中断后的下一个任务**: Task 3.1

---

### Epic 3: Backend Streaming Infrastructure / 后端流式基础设施

**Story Points**: 8
**Target Completion**: Week 2-3 / 目标完成：第2-3周

#### Task 3.1: WebSocket Streaming Endpoint / WebSocket流式端点

**File**: `backend/api/v1/streaming.py`
**Priority**: P0 (Critical)
**Estimated Time**: 3-4 days
**Depends On**: None

**Subtasks / 子任务**:

- [ ] **3.1.1** Set up WebSocket support in FastAPI
  - **File**: `backend/requirements.txt`
  - **Action**: Add `websockets` dependency
  - **Code**:
    ```python
    # requirements.txt
    websockets==11.0.3
    python-multipart==0.0.6
    ```

- [ ] **3.1.2** Create streaming endpoint
  - **File**: `backend/api/v1/streaming.py`
  - **Code**:
    ```python
    from fastapi import APIRouter, WebSocket, WebSocketDisconnect
    from typing import Dict
    import json
    import asyncio

    router = APIRouter()

    class ConnectionManager:
        def __init__(self):
            self.active_connections: Dict[str, WebSocket] = {}

        async def connect(self, websocket: WebSocket, session_id: str):
            await websocket.accept()
            self.active_connections[session_id] = websocket

        def disconnect(self, session_id: str):
            if session_id in self.active_connections:
                del self.active_connections[session_id]

        async def send_transcription(self, session_id: str, text: str, is_final: bool):
            if session_id in self.active_connections:
                await self.active_connections[session_id].send_json({
                    "text": text,
                    "is_final": is_final,
                    "timestamp": datetime.now().isoformat(),
                })

    manager = ConnectionManager()

    @router.websocket("/transcribe/stream")
    async def websocket_transcription_stream(
        websocket: WebSocket,
        session_id: str,
        token: str
    ):
        await manager.connect(websocket, session_id)
        try:
            while True:
                # Receive audio chunk
                data = await websocket.receive_bytes()

                # Process with STT
                result = await stt_service.process_chunk(data, session_id)

                # Send back transcription
                await manager.send_transcription(
                    session_id,
                    result.text,
                    result.is_final
                )
        except WebSocketDisconnect:
            manager.disconnect(session_id)
    ```

- [ ] **3.1.3** Implement session management
  - **File**: `backend/services/session_manager.py`
  - **Code**:
    ```python
    from datetime import datetime, timedelta
    from typing import Dict

    class TranscriptionSession:
        def __init__(self, session_id: str, user_id: str):
            self.session_id = session_id
            self.user_id = user_id
            self.created_at = datetime.now()
            self.last_activity = datetime.now()
            self.audio_chunks = []
            self.transcription_blocks = []

        def is_expired(self, timeout_minutes: int = 30) -> bool:
            return (datetime.now() - self.last_activity) > timedelta(minutes=timeout_minutes)

        def add_audio_chunk(self, chunk: bytes):
            self.audio_chunks.append(chunk)
            self.last_activity = datetime.now()

        def add_transcription(self, text: str, is_final: bool):
            self.transcription_blocks.append({
                "text": text,
                "is_final": is_final,
                "timestamp": datetime.now().isoformat(),
            })

    class SessionManager:
        def __init__(self):
            self.sessions: Dict[str, TranscriptionSession] = {}

        def create_session(self, session_id: str, user_id: str) -> TranscriptionSession:
            session = TranscriptionSession(session_id, user_id)
            self.sessions[session_id] = session
            return session

        def get_session(self, session_id: str) -> TranscriptionSession:
            return self.sessions.get(session_id)

        def cleanup_expired(self):
            expired = [sid for sid, s in self.sessions.items() if s.is_expired()]
            for sid in expired:
                del self.sessions[sid]
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 3.2

---

#### Task 3.2: Context Capture Service / 上下文捕获服务

**File**: `backend/services/context_capture.py`
**Priority**: P1 (High)
**Estimated Time**: 2-3 days
**Depends On**: Task 3.1

**Subtasks / 子任务**:

- [ ] **3.2.1** Implement location detection
  - **File**: `backend/services/context_capture.py`
  - **Code**:
    ```python
    import geopy
    from geopy.geocoders import Nominatim

    class LocationService:
        def __init__(self):
            self.geocoder = Nominatim(user_agent="echomemo")

        async def get_location_name(self, lat: float, lng: float) -> str:
            try:
                location = self.geocoder.reverse(f"{lat},{lng}")
                return location.address if location else "Unknown location"
            except Exception as e:
                print(f"Geocoding error: {e}")
                return "Unknown location"
    ```

- [ ] **3.2.2** Implement activity detection (basic)
  - **File**: `backend/services/context_capture.py`
  - **Code**:
    ```python
    class ActivityDetector:
        @staticmethod
        def detect_from_gps(speed: float) -> str:
            if speed < 0.5:  # < 0.5 m/s
                return "sitting"
            elif speed < 2:  # 0.5-2 m/s
                return "walking"
            elif speed > 5:  # > 5 m/s
                return "driving"
            else:
                return "moving"
    ```

- [ ] **3.2.3** Create context metadata model
  - **File**: `backend/models/context.py`
  - **Code**:
    ```python
    from sqlalchemy import Column, String, DateTime, JSON, ForeignKey
    from sqlalchemy.dialects.postgresql import UUID, DECIMAL
    import uuid

    class CapsuleContext(Base):
        __tablename__ = "capsule_context"

        id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
        capsule_id = Column(UUID(as_uuid=True), ForeignKey("thought_capsules.id"), nullable=False)
        context_type = Column(String(50), nullable=False)
        context_data = Column(JSON, nullable=False)
        captured_at = Column(DateTime(timezone=True), nullable=False)
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 3.3

---

#### Task 3.3: Database Optimization / 数据库优化

**File**: `backend/database.py`
**Priority**: P1 (High)
**Estimated Time**: 2-3 days
**Depends On**: None (can work in parallel)

**Subtasks / 子任务**:

- [ ] **3.3.1** Add database indexes for performance
  - **File**: `backend/migrations/001_add_indexes.py`
  - **Code**:
    ```sql
    -- Add composite indexes for common queries
    CREATE INDEX idx_capsules_user_created_desc ON thought_capsules(user_id, created_at DESC);
    CREATE INDEX idx_capsules_status ON thought_capsules(transcription_status)
      WHERE transcription_status = 'processing';

    -- Add GIN index for JSONB context queries
    CREATE INDEX idx_context_data_gin ON capsule_context USING GIN (context_data);
    ```

- [ ] **3.3.2** Implement connection pooling
  - **File**: `backend/database.py`
  - **Code**:
    ```python
    from sqlalchemy.pool import QueuePool

    engine = create_async_engine(
        DATABASE_URL,
        poolclass=QueuePool,
        pool_size=20,
        max_overflow=10,
        pool_pre_ping=True,  # Verify connections before using
        echo=False,
    )
    ```

- [ ] **3.3.3** Add database cleanup job
  - **File**: `backend/jobs/cleanup.py`
  - **Code**:
    ```python
    from apscheduler.schedulers.asyncio import AsyncIOScheduler

    scheduler = AsyncIOScheduler()

    @scheduler.scheduled_job('cron', hour=2)  # Run at 2 AM daily
    async def cleanup_old_sessions():
        session_manager.cleanup_expired()

    @scheduler.scheduled_job('cron', hour=3)  # Run at 3 AM daily
    async def cleanup_failed_transcriptions():
        # Delete capsules stuck in 'processing' for >24 hours
        cutoff = datetime.now() - timedelta(hours=24)
        await execute(
            "DELETE FROM thought_capsules WHERE transcription_status = 'processing' AND created_at < :cutoff",
            {"cutoff": cutoff}
        )
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 4.1

---

### Epic 4: Quality & Performance / 质量与性能

**Story Points**: 5
**Target Completion**: Week 4-5 / 目标完成：第4-5周

#### Task 4.1: Performance Monitoring / 性能监控

**File**: `frontend/lib/shared/utils/performance_monitor.dart`
**Priority**: P1 (High)
**Estimated Time**: 2 days
**Depends On**: None

**Subtasks / 子任务**:

- [ ] **4.1.1** Implement app launch time tracking
  - **File**: `frontend/lib/main.dart`
  - **Code**:
    ```dart
    class PerformanceMonitor {
      static final Map<String, DateTime> _markers = {};

      static void mark(String name) {
        _markers[name] = DateTime.now();
      }

      static Duration? getDuration(String startMarker, String endMarker) {
        final start = _markers[startMarker];
        final end = _markers[endMarker];
        if (start == null || end == null) return null;
        return end.difference(start);
      }

      static void reportMetrics() {
        final launchTime = getDuration('app_start', 'recording_ready');
        print('⚡ Launch time: ${launchTime?.inMilliseconds}ms');
      }
    }

    void main() {
      PerformanceMonitor.mark('app_start');
      runApp(EchoMemoApp());
      PerformanceMonitor.mark('recording_ready');
      PerformanceMonitor.reportMetrics();
    }
    ```

- [ ] **4.1.2** Add memory usage tracking
  - **File**: `frontend/lib/shared/utils/performance_monitor.dart`
  - **Code**:
    ```dart
    import 'dart:io';

    class MemoryMonitor {
      static int getMemoryUsage() {
        // Get current process memory usage in MB
        return ProcessInfo.currentRss ~/ (1024 * 1024);
      }

      static void logMemoryUsage(String context) {
        final usage = getMemoryUsage();
        print('💾 Memory at $context: ${usage}MB');
      }
    }
    ```

**Next Task After Interruption / 中断后的下一个任务**: Task 4.2

---

#### Task 4.2: User Testing & Feedback / 用户测试与反馈

**File**: `docs/tracking/user_feedback.md`
**Priority**: P1 (High)
**Estimated Time**: Ongoing
**Depends On**: All previous tasks

**Subtasks / 子任务**:

- [ ] **4.2.1** Create beta testing group
  - **Action**: Recruit 10-20 users
  - **Requirements**:
    - Mix of iOS and Android users
    - Different age groups
    - Various technical proficiency levels

- [ ] **4.2.2** Implement in-app feedback mechanism
  - **File**: `frontend/lib/features/feedback/widgets/feedback_button.dart`
  - **Code**:
    ```dart
    class FeedbackButton extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return FloatingActionButton(
          mini: true,
          onPressed: () => _showFeedbackDialog(),
          child: Icon(Icons.feedback),
        );
      }

      void _showFeedbackDialog() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Report Issue'),
            content: TextField(
              decoration: InputDecoration(hintText: 'Describe the issue...'),
              onChanged: (text) => _feedbackText = text,
            ),
            actions: [
              TextButton(
                onPressed: () => _submitFeedback(),
                child: Text('Submit'),
              ),
            ],
          ),
        );
      }
    }
    ```

- [ ] **4.2.3** Conduct weekly user interviews
  - **Frequency**: Weekly
  - **Duration**: 30 minutes per user
  - **Focus Questions**:
    - How long did it take from "I want to record" to actually recording?
    - Did you feel any hesitation before recording?
    - Did you feel your data was safe?
    - What was frustrating about the experience?

---

## Implementation Sequence / 实施顺序

### Week 1 / 第1周

**Focus**: Foundation / 基础

- [ ] Day 1-2: Task 1.1 (App Launch Optimization)
- [ ] Day 3-4: Task 1.2 (One-Tap Recording Interface)
- [ ] Day 5: Task 1.5 (Local Encrypted Storage) - Start
- [ ] Day 6-7: Task 1.5 (Local Encrypted Storage) - Complete

**Deliverables / 交付物**:
- ✅ App launches in <1.5s
- ✅ One-tap recording interface working
- ✅ Local encrypted storage implemented

---

### Week 2 / 第2周

**Focus**: Real-time Features / 实时功能

- [ ] Day 1-3: Task 1.3 (Background Transcription Service)
- [ ] Day 4-5: Task 1.4 (Waveform Visualization)
- [ ] Day 6-7: Task 3.1 (WebSocket Streaming Endpoint)

**Deliverables / 交付物**:
- ✅ Real-time transcription streaming working
- ✅ Waveform visualization synced with audio
- ✅ Backend WebSocket endpoint operational

---

### Week 3 / 第3周

**Focus**: Timeline & Context / 时间流与上下文

- [ ] Day 1-3: Task 2.1 (Timeline List Component)
- [ ] Day 4-5: Task 2.2 (Context Indicators)
- [ ] Day 6-7: Task 2.3 (Capsule Card Design)

**Deliverables / 交付物**:
- ✅ Timeline view displaying capsules
- ✅ Context indicators showing location, activity, time
- ✅ Interactive capsule cards

---

### Week 4 / 第4周

**Focus**: Backend & Polish / 后端与打磨

- [ ] Day 1-2: Task 3.2 (Context Capture Service)
- [ ] Day 3-4: Task 3.3 (Database Optimization)
- [ ] Day 5-6: Task 4.1 (Performance Monitoring)
- [ ] Day 7: Task 4.2 (User Testing) - Start

**Deliverables / 交付物**:
- ✅ Context capture service operational
- ✅ Database optimized
- ✅ Performance monitoring in place

---

### Week 5-6 / 第5-6周

**Focus**: Testing & Refinement / 测试与优化

- [ ] Week 5: Task 4.2 (User Testing) - Continue
- [ ] Week 6: Bug fixes, performance tuning
- [ ] Week 6: Prepare for Phase 2 transition

**Deliverables / 交付物**:
- ✅ All success metrics met
- ✅ Beta user feedback incorporated
- ✅ Phase 1 complete, ready for Phase 2

---

## Resumption Protocol / 恢复协议

### How to Resume Development / 如何恢复开发

**Scenario**: You've been away from the project for a while / **场景**：您有一段时间没有参与项目

#### Step 1: Check Progress / 检查进度

```bash
# Navigate to tracking docs
cd docs/tracking

# Read progress tracker
cat progress-tracker.md

# Check recent decisions
cat decision-log.md
```

#### Step 2: Identify Last Completed Task / 确定最后完成的任务

1. Open this document: [Phase 1 Plan](./phase-01-container.md)
2. Find "Task Breakdown" section / 查找"任务分解"部分
3. Look for checked ✅ items / 查找已勾选✅的项目
4. Find the last unchecked item / 找到最后一个未勾选的项目

**Example / 示例**:
```
Last completed: ✅ Task 1.2.2 (Implement haptic feedback)
Next task: [ ] Task 1.2.3 (Add stop recording gesture)
```

#### Step 3: Review Context / 回顾上下文

Read the task details:

阅读任务详情：

1. Check the file to modify / 检查要修改的文件
2. Review the code examples / 查看代码示例
3. Understand acceptance criteria / 理解验收标准
4. Check dependencies / 检查依赖项

#### Step 4: Resume Work / 恢复工作

```bash
# Pull latest changes
git pull origin main

# Checkout development branch (if exists)
git checkout -d feature/phase-1-task-1.2.3

# Install any new dependencies
cd frontend && flutter pub get
cd ../backend && pip install -r requirements.txt

# Start working
# Edit the file specified in the task
# Follow the code examples provided
```

#### Step 5: Mark Progress / 标记进度

When you complete a task:

完成任务时：

1. Check the ✅ box in this document / 在本文档中勾选✅框
2. Update [progress-tracker.md](../tracking/progress-tracker.md) / 更新进度追踪器
3. If you made a decision, update [decision-log.md](../tracking/decision-log.md) / 如果做出了决策，更新决策日志

---

## Quick Reference / 快速参考

### Current Status / 当前状态

**Phase**: 1 - The Container
**Week**: 2 of 6
**Last Updated**: 2025-02-15
**Next Milestone**: Complete real-time transcription (Week 2)

### Key Contacts / 关键联系人

- **Product Owner**: [TBD]
- **Tech Lead**: [TBD]
- **Design Lead**: [TBD]

### Related Documents / 相关文档

- [Product Philosophy](../DESIGN.md)
- [Progress Tracker](../tracking/progress-tracker.md)
- [Technical Decisions](../tracking/decision-log.md)
- [API Specifications](../architecture/api-design.md)

---

**Document Version**: v1.0.0
**Last Modified**: 2025-02-15
**Next Review**: 2025-02-22
