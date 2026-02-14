# EchoMemo Frontend / EchoMemo 前端

Flutter-based mobile and desktop application for EchoMemo voice journal.

基于 Flutter 的 EchoMemo 语音日记移动端和桌面应用。

## Features / 功能特性

- **Voice Recording** / **语音录制**: High-quality audio recording with Record package
- **Real-time Visualization** / **实时可视化**: Audio waveform visualization during recording
- **Auto-refresh** / **自动刷新**: Automatic UI updates when processing completes
- **Bilingual UI** / **双语界面**: English and Chinese support
- **Material Design 3** / **Material Design 3**: Modern, adaptive UI design
- **Search & Filter** / **搜索过滤**: Full-text search across memos
- **Mood Tracking** / **情绪追踪**: Visual mood indicators with sentiment analysis
- **Tag Management** / **标签管理**: Organize memos with AI-generated tags

## Tech Stack / 技术栈

- **Framework**: Flutter 3.41+
- **Language**: Dart
- **State Management**: Provider pattern
- **Audio Recording**: Record package (v6.0+)
- **Audio Playback**: Audioplayers package (v6.0+)
- **HTTP Client**: Dio for API requests
- **Platforms Supported**:
  - iOS (14+)
  - Android (5.0+)
  - macOS (10.15+)
  - Windows (10+)
  - Linux

## Project Structure / 项目结构

```
frontend/
├── lib/
│   ├── main.dart              # App entry point / 应用入口
│   ├── models/                # Data models / 数据模型
│   │   └── memo.dart          # Memo model / 笔记模型
│   ├── screens/               # UI screens / 界面
│   │   ├── home_screen.dart   # Home screen with memo list / 主界面
│   │   ├── recorder_screen.dart # Audio recording / 录音界面
│   │   └── login_screen.dart  # Authentication / 登录界面
│   ├── services/              # Services / 服务层
│   │   ├── api_service.dart   # API client / API客户端
│   │   └── auth_service.dart  # Auth manager / 认证管理
│   └── widgets/               # Reusable widgets / 可复用组件
├── android/                   # Android configuration
├── ios/                       # iOS configuration
├── macos/                     # macOS configuration
├── windows/                   # Windows configuration
├── linux/                     # Linux configuration
├── pubspec.yaml               # Dependencies / 依赖配置
└── README.md                  # This file / 本文件
```

## Quick Start / 快速开始

### Prerequisites / 前置要求

1. **Install Flutter / 安装 Flutter**:
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Or use Homebrew (macOS): / 或使用 Homebrew (macOS):
     ```bash
     brew install flutter
     ```

2. **Verify installation / 验证安装**:
   ```bash
   flutter doctor
   ```

3. **Platform Requirements / 平台要求**:
   - **iOS/macOS**: Xcode 14+
   - **Android**: Android Studio with SDK
   - **Windows**: Visual Studio 2022 with C++ desktop development
   - **Linux**: Clang and CMake

### Installation / 安装

1. **Navigate to frontend directory / 进入前端目录**:
   ```bash
   cd frontend
   ```

2. **Install dependencies / 安装依赖**:
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint / 配置 API 地址**:

   Edit `lib/services/api_service.dart`:

   编辑 `lib/services/api_service.dart`:

   ```dart
   // Change to your backend server URL
   // 修改为你的后端服务器地址
   static const String baseUrl = 'http://your-server-ip:8000';
   ```

4. **Run the app / 运行应用**:

   **On macOS / 在 macOS 上**:
   ```bash
   flutter run -d macos
   ```

   **On iOS / 在 iOS 上**:
   ```bash
   flutter run -d ios
   ```

   **On Android / 在 Android 上**:
   ```bash
   flutter run -d android
   ```

   **On Windows / 在 Windows 上**:
   ```bash
   flutter run -d windows
   ```

   Or simply / 或简单地:
   ```bash
   flutter run
   ```

## Configuration / 配置

### API Service Configuration / API 服务配置

The app needs to connect to your backend server. Update the base URL:

应用需要连接到后端服务器。更新基础 URL：

**File**: `lib/services/api_service.dart`

```dart
class ApiService extends ChangeNotifier {
  // Development / 开发环境
  static const String baseUrl = 'http://localhost:8000';

  // Production / 生产环境
  // static const String baseUrl = 'http://your-server-ip:8000';
}
```

### Platform-Specific Setup / 平台特定设置

#### iOS / iPadOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Add microphone permission in `Info.plist`:
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to record voice memos.</string>
   ```

#### Android

1. Add permissions in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

2. Set minimum SDK in `android/app/build.gradle`:
   ```gradle
   minSdkVersion 21
   ```

#### macOS

1. Add microphone permission in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:
   ```xml
   <key>com.apple.security.device.microphone</key>
   <true/>
   ```

#### Windows

No special configuration needed. Audio permissions are handled automatically.

无需特殊配置。音频权限自动处理。

#### Linux

Install dependencies on Linux:

在 Linux 上安装依赖：

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## Build for Production / 生产环境构建

### Android APK / Android APK 构建

```bash
# Debug version
flutter build apk --debug

# Release version
flutter build apk --release

# Split APKs by architecture
flutter build apk --split-per-abi --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA / iOS IPA 构建

```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Or build from command line (requires signing)
flutter build ios --release
```

### macOS App / macOS 应用构建

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/echomemo.app`

### Windows EXE / Windows 可执行文件构建

```bash
flutter build windows --release
```

Output: `build\windows\runner\Release\`

### Linux Executable / Linux 可执行文件构建

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

## Key Components / 核心组件

### Home Screen / 主界面 (`home_screen.dart`)

- Displays list of voice memos / 显示语音笔记列表
- Auto-refreshes when processing is in progress / 处理中时自动刷新
- Search and filter functionality / 搜索和过滤功能
- Material Design 3 cards with mood indicators / Material Design 3 卡片带情绪指示器

### Recorder Screen / 录音界面 (`recorder_screen.dart`)

- Audio recording with waveform visualization / 带波形可视化的音频录制
- Recording controls (record, stop, upload) / 录制控制（录制、停止、上传）
- Real-time duration display / 实时时长显示

### API Service / API 服务 (`api_service.dart`)

- Handles all HTTP requests / 处理所有 HTTP 请求
- JWT token management / JWT 令牌管理
- Error handling / 错误处理

## Troubleshooting / 故障排除

### Issue: Flutter command not found / 问题：找不到 Flutter 命令

**Solution**:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

Add to `~/.zshrc` or `~/.bashrc` for permanent setup.

### Issue: "Flutter SDK not found" in VS Code / 问题：VS Code 中找不到 Flutter SDK

**Solution**: Install Flutter extension and set Flutter SDK path in settings.

### Issue: Build fails on iOS / 问题：iOS 构建失败

**Solution**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter build ios
```

### Issue: Recording not working / 问题：录音不工作

**Solution**:
- Check microphone permissions / 检查麦克风权限
- Ensure platform-specific setup is complete / 确保平台特定设置完成
- Test on physical device (simulator may have issues) / 在真机上测试（模拟器可能有问题）

### Issue: Auto-refresh not working / 问题：自动刷新不工作

**Solution**:
- Ensure backend is running / 确保后端正在运行
- Check API endpoint configuration / 检查 API 端点配置
- Look for console logs showing refresh attempts / 查看控制台日志中的刷新尝试

## Development / 开发

### Hot Reload / 热重载

While the app is running, press:

应用运行时，按：

- `r` - Hot reload / 热重载
- `R` - Hot restart / 热重启
- `q` - Quit / 退出

### Debugging / 调试

```bash
# Run with verbose logging
flutter run -d macos --verbose

# Run with observatory
flutter run -d macos --observatory-port=8888
```

### Code Formatting / 代码格式化

```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

## Architecture / 架构

The app follows the **Provider pattern** for state management:

应用遵循 **Provider 模式** 进行状态管理：

```
main.dart
    ↓
MultiProvider (ApiService, AuthService)
    ↓
MaterialApp
    ↓
Screens (Consumer of services)
    ↓
Widgets
```

### Data Flow / 数据流

```
User Action → Screen Widget → ApiService
                              ↓
                         HTTP Request
                              ↓
                           Backend
                              ↓
                         Response
                              ↓
                  Update State (notifyListeners)
                              ↓
                    UI Auto Updates
```

## UI Design / 界面设计

The app uses Material Design 3 with adaptive theming:

应用使用 Material Design 3 和自适应主题：

- **Light Mode / 浅色模式**: Clean, modern interface
- **Dark Mode / 深色模式**: Easy on the eyes
- **Mood Colors**:
  - Positive (Green) / 积极（绿色）
  - Neutral (Amber) / 中性（琥珀色）
  - Negative (Red) / 消极（红色）

## Performance Optimization / 性能优化

- **Lazy Loading**: Memos loaded on demand
- **Image Caching**: Profile pictures cached
- **Pagination**: Load memos in batches (future)
- **Debouncing**: Search queries debounced

## Contributing / 贡献

Contributions welcome! Please:

欢迎贡献！请：

1. Follow Flutter style guide / 遵循 Flutter 代码规范
2. Use meaningful variable names / 使用有意义的变量名
3. Add comments for complex logic / 为复杂逻辑添加注释
4. Test on multiple platforms / 在多个平台上测试

## License / 许可证

MIT License

## Support / 支持

For issues and questions: / 如有问题，请访问：

- GitHub Issues: [EchoMemo Issues](https://github.com/myjnathan/EchoMemo/issues)
- Flutter Docs: [flutter.dev](https://flutter.dev/docs)

## Roadmap / 路线图

- [ ] Offline support with local storage / 使用本地存储的离线支持
- [ ] Widget support (iOS/macOS) / Widget 支持
- [ ] Audio playback in app / 应用内音频播放
- [ ] Export memos as text/PDF / 导出笔记为文本/PDF
- [ ] Cloud sync / 云同步
