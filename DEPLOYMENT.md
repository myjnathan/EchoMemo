# EchoMemo Deployment Guide / EchoMemo 部署指南

Complete step-by-step deployment guide for EchoMemo voice journal application.

EchoMemo 语音日记应用的完整分步部署指南。

---

## Table of Contents / 目录

1. [Prerequisites / 前置要求](#prerequisites--前置要求)
2. [Getting API Keys / 获取 API 密钥](#getting-api-keys--获取-api-密钥)
3. [Backend Deployment / 后端部署](#backend-deployment--后端部署)
4. [Frontend Deployment / 前端部署](#frontend-deployment--前端部署)
5. [Production Deployment / 生产部署](#production-deployment--生产部署)
6. [Troubleshooting / 故障排除](#troubleshooting--故障排除)

---

## Prerequisites / 前置要求

### For Backend / 后端要求

- **Operating System / 操作系统**:
  - Linux (Ubuntu 20.04+, CentOS 7+) / Linux (Ubuntu 20.04+, CentOS 7+)
  - macOS 10.15+
  - Windows 10+ with WSL2

- **Software Required / 必需软件**:
  - Python 3.9 or higher / Python 3.9 或更高版本
  - Docker 20.10+ and Docker Compose 2.0+
  - Git
  - Text editor (VS Code recommended) / 文本编辑器（推荐 VS Code）

### For Frontend / 前端要求

- **Flutter SDK** 3.41 or higher / Flutter SDK 3.41 或更高版本
- **Platform-specific SDKs**:
  - **iOS/macOS**: Xcode 14+
  - **Android**: Android Studio with SDK 21+
  - **Windows**: Visual Studio 2022 with C++ desktop development

### Verify Installations / 验证安装

```bash
# Check Python
python3 --version  # Should be 3.9+

# Check Docker
docker --version
docker-compose --version

# Check Git
git --version

# Check Flutter (for frontend)
flutter --version
```

---

## Getting API Keys / 获取 API 密钥

EchoMemo requires two external services:

EchoMemo 需要两个外部服务：

### 1. DeepSeek LLM API (Required / 必需)

Used for text analysis, summarization, and sentiment analysis.

用于文本分析、摘要和情绪分析。

**Steps / 步骤**:

1. Visit DeepSeek Open Platform / 访问 DeepSeek 开放平台: https://platform.deepseek.com/
2. Register / login / 注册或登录
3. Go to API Keys section / 进入 API Keys 部分
4. Create new API key / 创建新的 API key
5. Copy the key (format: `sk-xxxxx...`) / 复制密钥（格式：`sk-xxxxx...`）

**Save this key** - you'll need it later for `.env` configuration.

**保存此密钥** - 稍后配置 `.env` 时需要。

### 2. Volcengine STT API (Optional / 可选)

Used for speech-to-text transcription (Chinese language optimized).

用于语音转文字（中文优化）。

**Steps / 步骤**:

1. Visit Volcengine Cloud / 访问火山引擎云: https://console.volcengine.com/speech/service
2. Register / login / 注册或登录
3. Enable "Speech Recognition" service / 启用"语音识别"服务
4. Create application / 创建应用
5. Get credentials / 获取凭据:
   - **App ID** / **应用 ID**
   - **Access Key** / **访问密钥**
   - **Secret Key** / **密钥**

**Alternative / 替代方案**: If you don't want to use Volcengine, you can integrate other STT services like:

如果您不想使用火山引擎，可以集成其他 STT 服务：

- OpenAI Whisper API
- Google Cloud Speech-to-Text
- Azure Speech Services
- Aliyun (Alibaba Cloud) Speech Recognition

---

## Backend Deployment / 后端部署

### Option A: Local Development / 本地开发

For development and testing on your local machine.

在本地机器上进行开发和测试。

#### Step 1: Clone Repository / 克隆仓库

```bash
# Navigate to your workspace
cd /path/to/your/workspace

# Clone the repository
git clone https://github.com/myjnathan/EchoMemo.git
cd EchoMemo/backend
```

#### Step 2: Create Virtual Environment / 创建虚拟环境

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

#### Step 3: Install Dependencies / 安装依赖

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### Step 4: Configure Environment / 配置环境

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your favorite editor
nano .env
```

**Update the following values in `.env`**:

**在 `.env` 中更新以下值**：

```bash
# DeepSeek LLM API (Required / 必需)
LLM_API_KEY=sk-your-actual-deepseek-key-here
LLM_BASE_URL=https://api.deepseek.com/v1

# Volcengine STT API (Optional / 可选)
STT_ACCESS_KEY=your-volcengine-access-key
STT_SECRET_KEY=your-volcengine-secret-key
STT_APP_ID=your-volcengine-app-id
SERVER_URL=http://localhost:8000/uploads

# Database (for local development)
DATABASE_URL=sqlite:///./echomemo.db

# Security (change this in production!)
SECRET_KEY=change-this-to-a-random-secret-key
```

#### Step 5: Run Backend Server / 运行后端服务器

```bash
# Development mode with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Expected output / 预期输出**:

```
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

#### Step 6: Verify Backend / 验证后端

Open your browser and visit:

打开浏览器访问：

- **API Root**: http://localhost:8000/
- **API Documentation (Swagger)**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

---

### Option B: Docker Deployment / Docker 部署

Recommended for production and consistent environments.

推荐用于生产和一致的环境。

#### Step 1: Clone Repository / 克隆仓库

```bash
git clone https://github.com/myjnathan/EchoMemo.git
cd EchoMemo/backend
```

#### Step 2: Configure Environment / 配置环境

```bash
cp .env.example .env
nano .env  # Edit with your API keys
```

**Important / 重要**: Update `SERVER_URL` to your public IP or domain:

**重要**: 将 `SERVER_URL` 更新为您的公网 IP 或域名：

```bash
SERVER_URL=http://YOUR_PUBLIC_IP:8000/uploads
```

#### Step 3: Build Docker Image / 构建 Docker 镜像

```bash
docker build -t echomemo-backend .
```

#### Step 4: Run Docker Container / 运行 Docker 容器

```bash
# Create uploads directory
mkdir -p uploads

# Run container
docker run -d \
  --name echomemo-backend \
  -p 8000:8000 \
  --env-file .env \
  -v $(pwd)/uploads:/app/uploads \
  echomemo-backend
```

#### Step 5: Verify Container / 验证容器

```bash
# Check container status
docker ps | grep echomemo-backend

# View logs
docker logs echomemo-backend -f

# Test API
curl http://localhost:8000/health
```

---

### Option C: Docker Compose (With Database) / Docker Compose（带数据库）

Complete setup with PostgreSQL database.

包含 PostgreSQL 数据库的完整设置。

#### Step 1: Create docker-compose.yml / 创建 docker-compose.yml

```yaml
version: '3.8'

services:
  backend:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://echouser:echopass@db:5432/echomemo
      - SECRET_KEY=${SECRET_KEY}
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_BASE_URL=${LLM_BASE_URL}
      - STT_ACCESS_KEY=${STT_ACCESS_KEY}
      - STT_SECRET_KEY=${STT_SECRET_KEY}
      - STT_APP_ID=${STT_APP_ID}
      - SERVER_URL=${SERVER_URL}
    volumes:
      - ./uploads:/app/uploads
    depends_on:
      - db
    restart: always

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=echouser
      - POSTGRES_PASSWORD=echopass
      - POSTGRES_DB=echomemo
    volumes:
      - echomemo_postgres_data:/var/lib/postgresql/data
    restart: always

volumes:
  echomemo_postgres_data:
```

#### Step 2: Start Services / 启动服务

```bash
# Start all services
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Check status
docker-compose ps
```

---

## Frontend Deployment / 前端部署

### Option A: Development Mode / 开发模式

Run Flutter app on your development machine.

在开发机器上运行 Flutter 应用。

#### Step 1: Install Flutter / 安装 Flutter

```bash
# On macOS
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

#### Step 2: Navigate to Frontend / 进入前端目录

```bash
cd EchoMemo/frontend
```

#### Step 3: Install Dependencies / 安装依赖

```bash
flutter pub get
```

#### Step 4: Configure API Endpoint / 配置 API 端点

Edit `lib/services/api_service.dart`:

编辑 `lib/services/api_service.dart`：

```dart
class ApiService extends ChangeNotifier {
  // For local development
  static const String baseUrl = 'http://localhost:8000';

  // For Docker/production
  // static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
}
```

#### Step 5: Run App / 运行应用

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d macos      # macOS
flutter run -d ios        # iOS
flutter run -d android    # Android
flutter run -d chrome     # Web browser

# Or let Flutter choose
flutter run
```

---

### Option B: Build for Production / 生产构建

Build standalone executables or app bundles.

构建独立的可执行文件或应用包。

#### Build for macOS / macOS 构建

```bash
cd frontend
flutter build macos --release

# Output: build/macos/Build/Products/Release/echomemo.app
```

#### Build for Android / Android 构建

```bash
cd frontend

# Release APK
flutter build apk --release

# Split by ABI (smaller APKs)
flutter build apk --split-per-abi --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Build for iOS / iOS 构建

```bash
cd frontend

# Requires Xcode and Apple Developer account
# 需要Xcode和Apple开发者账户

flutter build ios --release

# Open in Xcode for final build and signing
open ios/Runner.xcworkspace
```

---

## Production Deployment / 生产部署

### Deploy to Linux Server / 部署到 Linux 服务器

Complete production deployment on a cloud server (VPS).

在云服务器（VPS）上完整生产部署。

#### Step 1: Connect to Server / 连接到服务器

```bash
# SSH to your server
ssh root@YOUR_SERVER_IP
```

#### Step 2: Install Docker / 安装 Docker

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

#### Step 3: Clone Repository / 克隆仓库

```bash
# Install Git
sudo apt-get install git -y

# Clone repository
cd /opt
git clone https://github.com/myjnathan/EchoMemo.git
cd EchoMemo/backend
```

#### Step 4: Configure Environment / 配置环境

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Production `.env` example**:

**生产环境 `.env` 示例**：

```bash
# Database
DATABASE_URL=postgresql://echouser:echopass@db:5432/echomemo
POSTGRES_USER=echouser
POSTGRES_PASSWORD=STRONG_RANDOM_PASSWORD_HERE
POSTGRES_DB=echomemo

# Security (IMPORTANT: Use strong random key!)
SECRET_KEY=$(openssl rand -hex 32)

# DeepSeek API
LLM_API_KEY=sk-your-deepseek-key
LLM_BASE_URL=https://api.deepseek.com/v1

# Volcengine STT
STT_ACCESS_KEY=your-access-key
STT_SECRET_KEY=your-secret-key
STT_APP_ID=your-app-id

# Server URL (IMPORTANT: Use public IP or domain!)
SERVER_URL=http://YOUR_PUBLIC_IP:8000/uploads
```

#### Step 5: Start Services / 启动服务

```bash
# Build and start
docker-compose up -d --build

# Wait for services to be healthy
sleep 10

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend
```

#### Step 6: Verify Deployment / 验证部署

```bash
# From your local machine, test the API
curl http://YOUR_SERVER_IP:8000/health

# Expected: {"status":"ok"}
```

---

## Troubleshooting / 故障排除

### Backend Issues / 后端问题

#### Problem: Port 8000 already in use / 端口 8000 已被占用

**Solution / 解决方案**:

```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 PID
```

#### Problem: Database connection failed / 数据库连接失败

**Solution / 解决方案**:

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check database logs
docker-compose logs db

# Verify DATABASE_URL in .env
cat .env | grep DATABASE_URL
```

#### Problem: STT transcription fails / STT 转写失败

**Common causes / 常见原因**:

1. **Invalid audio format** / **无效的音频格式**:
   - Ensure file is valid M4A/MP3/WAV
   - 确保文件是有效的 M4A/MP3/WAV

2. **Server URL not accessible** / **服务器 URL 不可访问**:
   - Check `SERVER_URL` in .env
   - Ensure file is accessible from internet
   - 检查 .env 中的 `SERVER_URL`
   - 确保文件可从互联网访问

---

### Frontend Issues / 前端问题

#### Problem: Can't connect to backend / 无法连接到后端

**Solution / 解决方案**:

1. Check backend is running:
   ```bash
   curl http://YOUR_SERVER_IP:8000/health
   ```

2. Verify baseUrl in frontend code:
   ```dart
   // lib/services/api_service.dart
   static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
   ```

3. For Android emulator, use:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000';
   ```

---

## Support & Resources / 支持和资源

- **GitHub Issues**: https://github.com/myjnathan/EchoMemo/issues
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Flutter Docs**: https://flutter.dev/docs
- **Docker Docs**: https://docs.docker.com/

---

## License / 许可证

MIT License

---

**Last Updated / 最后更新**: 2025-02-15
