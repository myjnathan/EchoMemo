# EchoMemo - AI Voice Journal / AI 语音日记

[![Flutter](https://img.shields.io/badge/Flutter-3.41+-blue.svg)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.9+-yellow.svg)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)

**EchoMemo** is a modern voice journal application that combines the power of AI with the simplicity of voice recording.

**EchoMemo** 是一个结合了 AI 能力和语音录音简洁性的现代语音日记应用。

---

## ✨ Features / 功能特性

- 🎤 **Voice Recording** / **语音录制**: High-quality audio recording with waveform visualization
- 🤖 **AI-Powered Analysis** / **AI 智能分析**: Automatic transcription and sentiment analysis
- 📝 **Smart Summarization** / **智能摘要**: AI-generated summaries of your voice memos
- 😊 **Mood Tracking** / **情绪追踪**: Track your emotional patterns over time
- 🏷️ **Auto-Tagging** / **自动标签**: Intelligent tag generation based on content
- 🔄 **Real-time Sync** / **实时同步**: Automatic updates when processing completes
- 🌗 **Dark Mode** / **深色模式**: Beautiful Material Design 3 interface
- 🔍 **Full-text Search** / **全文搜索**: Search across all your voice memos
- 📱 **Cross-platform** / **跨平台**: iOS, Android, macOS, Windows, Linux

---

## 🏗️ Architecture / 架构

```
┌─────────────────────────────────────────────────┐
│                 Flutter App                     │
│              (Frontend UI)                      │
│         iOS / Android / Desktop                 │
└──────────────────┬──────────────────────────────┘
                   │ HTTP/HTTPS
                   ↓
┌────────────────────────────────────────────┐
│          FastAPI Backend                   │
│          (Python 3.9+)                     │
│  • JWT Authentication                      │
│  • RESTful API                             │
│  • Background Task Processing              │
└─────────────┬──────────────┬───────────────┘
              │              │
              ↓              ↓
     ┌────────────┐   ┌────────────┐
     │ PostgreSQL │   │   AI APIs  │
     │  Database  │   │  (STT+LLM) │
     └────────────┘   └────────────┘
```

---

## 🛠️ Tech Stack / 技术栈

### Frontend / 前端
- **Framework**: Flutter 3.41+ (Dart)
- **State Management**: Provider pattern
- **Audio**: Record package (v6.0+)
- **Platforms**: iOS 14+, Android 5.0+, macOS 10.15+, Windows 10+, Linux

### Backend / 后端
- **Framework**: FastAPI 0.104+ (Python 3.9+)
- **Database**: PostgreSQL 15 (production) / SQLite (development)
- **ORM**: SQLAlchemy
- **Authentication**: JWT (OAuth2)
- **Deployment**: Docker + Docker Compose

### AI Services / AI 服务
- **STT (Speech-to-Text)**: Volcengine API (Chinese optimized)
- **LLM (Text Analysis)**: DeepSeek API
  - Summarization
  - Sentiment analysis
  - Tag generation

---

## 📂 Project Structure / 项目结构

```
EchoMemo/
├── frontend/                 # Flutter mobile/desktop app
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── models/          # Data models
│   │   ├── screens/         # UI screens
│   │   │   ├── home_screen.dart
│   │   │   ├── recorder_screen.dart
│   │   │   └── login_screen.dart
│   │   └── services/        # API services
│   ├── android/             # Android config
│   ├── ios/                 # iOS config
│   ├── macos/               # macOS config
│   ├── pubspec.yaml         # Dependencies
│   └── README.md            # Frontend documentation
│
├── backend/                 # FastAPI backend
│   ├── main.py              # FastAPI app
│   ├── config.py            # Configuration
│   ├── database.py          # Database setup
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── auth.py              # Authentication
│   ├── services/            # Service layer
│   │   ├── stt.py          # Speech-to-Text
│   │   └── llm.py          # LLM analysis
│   ├── requirements.txt     # Python dependencies
│   ├── Dockerfile          # Docker config
│   ├── .env.example        # Environment template
│   └── README.md            # Backend documentation
│
├── DEPLOYMENT.md            # Complete deployment guide
└── README.md                # This file
```

---

## 🚀 Quick Start / 快速开始

### Prerequisites / 前置要求

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.41+
- [Python](https://python.org) 3.9+
- [Docker](https://docker.com) & Docker Compose
- API keys from [DeepSeek](https://platform.deepseek.com/) (LLM)
- Optional: [Volcengine](https://console.volcengine.com/speech/service) (STT)

### 1. Clone Repository / 克隆仓库

```bash
git clone https://github.com/myjnathan/EchoMemo.git
cd EchoMemo
```

### 2. Backend Setup / 后端设置

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
nano .env  # Add your API keys

# Run backend (development)
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend will be available at: http://localhost:8000

后端地址：http://localhost:8000

### 3. Frontend Setup / 前端设置

```bash
cd frontend

# Install dependencies
flutter pub get

# Configure API endpoint
# Edit lib/services/api_service.dart
# Set baseUrl to 'http://localhost:8000'

# Run app
flutter run
```

---

## 📖 Documentation / 文档

- **[Deployment Guide / 部署指南](./DEPLOYMENT.md)**
  - Complete step-by-step deployment instructions
  - 完整的分步部署说明

- **[Backend README / 后端文档](./backend/README.md)**
  - API documentation
  - Backend architecture
  - Configuration guide

- **[Frontend README / 前端文档](./frontend/README.md)**
  - Flutter setup guide
  - Build instructions
  - Platform-specific configuration

---

## 🔑 Environment Variables / 环境变量

Copy `.env.example` to `.env` and configure:

复制 `.env.example` 到 `.env` 并配置：

```bash
# DeepSeek LLM API (Required / 必需)
LLM_API_KEY=sk-your-deepseek-api-key
LLM_BASE_URL=https://api.deepseek.com/v1

# Volcengine STT API (Optional / 可选)
STT_ACCESS_KEY=your-volcengine-access-key
STT_SECRET_KEY=your-volcengine-secret-key
STT_APP_ID=your-volcengine-app-id
SERVER_URL=http://localhost:8000/uploads

# Database
DATABASE_URL=sqlite:///./echomemo.db

# Security
SECRET_KEY=your-random-secret-key
```

⚠️ **Important / 重要**: Never commit `.env` to version control!

⚠️ **重要**：永远不要将 `.env` 提交到版本控制！

---

## 🐳 Docker Deployment / Docker 部署

### Quick Start / 快速启动

```bash
cd backend

# Build and start with Docker Compose
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

The API will be available at: http://localhost:8000

API 地址：http://localhost:8000

---

## 📱 Building for Production / 生产构建

### Android / 安卓

```bash
cd frontend
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS / 苹果

```bash
cd frontend
flutter build ios --release

# Requires Xcode and Apple Developer account
# 需要 Xcode 和 Apple 开发者账户
```

### macOS / Mac

```bash
cd frontend
flutter build macos --release

# Output: build/macos/Build/Products/Release/echomemo.app
```

---

## 🧪 Testing / 测试

### Backend Tests / 后端测试

```bash
cd backend

# Run tests
pytest

# With coverage
pytest --cov=.
```

### API Documentation / API 文档

Once backend is running, visit:

后端运行后，访问：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🎨 Screenshots / 截图

*Coming soon...*

*即将推出...*

---

## 🤝 Contributing / 贡献

Contributions are welcome! Please feel free to submit a Pull Request.

欢迎贡献！请随时提交 Pull Request。

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 Roadmap / 路线图

- [ ] Offline support with local storage
- [ ] Audio playback in app
- [ ] Export memos as PDF/Markdown
- [ ] Cloud backup and sync
- [ ] Widget support (iOS/macOS)
- [ ] Multi-language support for UI
- [ ] Voice commands
- [ ] Integration with calendars

---

## 🔒 Security / 安全

- ⚠️ **Never commit `.env` file** - It contains sensitive API keys
- ⚠️ **永远不要提交 `.env` 文件** - 它包含敏感的 API 密钥
- 🔐 Use strong `SECRET_KEY` in production / 生产环境使用强密码
- 🛡️ Enable HTTPS in production / 生产环境启用 HTTPS
- 🔑 Rotate API keys regularly / 定期轮换 API 密钥

---

## 🐛 Troubleshooting / 故障排除

### Common Issues / 常见问题

**Problem**: Backend won't start / 后端无法启动
```bash
# Check if port 8000 is in use
lsof -i :8000
# Kill the process if needed
kill -9 PID
```

**Problem**: Flutter command not found / 找不到 Flutter 命令
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
# Add to ~/.zshrc or ~/.bashrc for permanent setup
```

**Problem**: API returns 500 error / API 返回 500 错误
```bash
# Check backend logs
docker logs echomemo-backend -f
# Or with docker-compose
docker-compose logs backend -f
```

For more troubleshooting tips, see [DEPLOYMENT.md](./DEPLOYMENT.md).

更多故障排除技巧，请参阅 [DEPLOYMENT.md](./DEPLOYMENT.md)。

---

## 📄 License / 许可证

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

---

## 📞 Support / 支持

- **GitHub Issues**: [Submit issues](https://github.com/myjnathan/EchoMemo/issues)
- **Documentation**: [Full docs](./DEPLOYMENT.md)
- **API Docs**: http://localhost:8000/docs (when backend is running)

---

## 🙏 Acknowledgments / 致谢

- [FastAPI](https://fastapi.tiangolo.com/) - Modern, fast web framework for building APIs
- [Flutter](https://flutter.dev) - Beautiful, natively compiled applications
- [DeepSeek](https://www.deepseek.com/) - Advanced AI language model
- [Volcengine](https://www.volcengine.com/) - Speech recognition services

---

## 📊 Project Status / 项目状态

✅ **Backend**: Stable / 稳定
✅ **Frontend**: Stable / 稳定
✅ **Docker**: Tested / 已测试
⚠️ **Production**: Use at your own risk / 生产环境使用需自担风险

---

**Made with ❤️ by EchoMemo Team**

**用 ❤️ 打造，EchoMemo 团队**
