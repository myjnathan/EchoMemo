# EchoMemo Backend / EchoMemo 后端

FastAPI-based backend for EchoMemo voice journal application with speech-to-text and AI analysis.

基于 FastAPI 的 EchoMemo 语音日记应用后端，提供语音转文字和 AI 分析功能。

## Features / 功能特性

- **Speech-to-Text (STT)** / **语音转文字**: Volcengine API integration
- **AI Analysis** / **AI 智能分析**: DeepSeek LLM for summarization and sentiment analysis
- **User Authentication** / **用户认证**: JWT token-based authentication
- **RESTful API** / **RESTful 接口**: Complete CRUD operations for voice memos
- **Background Processing** / **后台处理**: Async task processing for audio files
- **Database Support** / **数据库支持**: SQLite (dev) and PostgreSQL (production)

## Tech Stack / 技术栈

- **Framework**: FastAPI 0.104+
- **Database**: SQLAlchemy ORM with SQLite/PostgreSQL
- **Authentication**: JWT (OAuth2)
- **STT Service**: Volcengine (字节跳动火山引擎)
- **LLM Service**: DeepSeek API
- **Deployment**: Docker + Docker Compose

## Project Structure / 项目结构

```
backend/
├── main.py                 # FastAPI application entry point / 应用入口
├── config.py               # Configuration settings / 配置文件
├── database.py             # Database connection / 数据库连接
├── models.py               # SQLAlchemy models / 数据模型
├── schemas.py              # Pydantic schemas / 数据验证模型
├── auth.py                 # Authentication utilities / 认证工具
├── services/               # Service layer / 服务层
│   ├── stt.py             # Speech-to-Text service / 语音转文字
│   └── llm.py             # LLM analysis service / AI分析服务
├── requirements.txt        # Python dependencies / Python依赖
├── Dockerfile             # Docker configuration / Docker配置
├── .env.example           # Environment template / 环境变量模板
└── README.md              # This file / 本文件
```

## Quick Start / 快速开始

### Prerequisites / 前置要求

- Python 3.9+
- pip or conda

### Installation / 安装

1. **Clone repository / 克隆仓库**:
```bash
cd backend
```

2. **Create virtual environment / 创建虚拟环境**:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies / 安装依赖**:
```bash
pip install -r requirements.txt
```

4. **Configure environment / 配置环境变量**:
```bash
cp .env.example .env
# Edit .env and add your API keys
```

5. **Run the server / 运行服务器**:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API will be available at: http://localhost:8000

### API Documentation / API 文档

Once the server is running, visit:

服务器运行后，访问：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Environment Variables / 环境变量

Required environment variables in `.env`:

必需的环境变量：

```bash
# DeepSeek LLM API
LLM_API_KEY=sk-xxxxxxxxxxxxxx
LLM_BASE_URL=https://api.deepseek.com/v1

# Volcengine STT API (火山引擎)
STT_ACCESS_KEY=your_access_key
STT_SECRET_KEY=your_secret_key
STT_APP_ID=your_app_id

# Server Configuration
SERVER_URL=http://localhost:8000/uploads

# Database
DATABASE_URL=sqlite:///./echomemo.db

# Security
SECRET_KEY=your_secret_key_for_jwt
```

## API Endpoints / API 接口

### Authentication / 认证

- `POST /token` - Get access token / 获取访问令牌
- `POST /users/` - Register new user / 注册新用户

### Memos / 笔记管理

- `GET /memos` - List all memos / 获取所有笔记
- `GET /memos/{id}` - Get specific memo / 获取特定笔记
- `POST /upload` - Upload audio file / 上传音频文件

### System / 系统

- `GET /` - API status / API状态
- `GET /health` - Health check / 健康检查

## Development / 开发

### Running Tests / 运行测试

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

### Database Migrations / 数据库迁移

The app uses SQLAlchemy auto-create for tables. For production, consider using Alembic.

应用使用 SQLAlchemy 自动创建表。生产环境建议使用 Alembic。

## Docker Deployment / Docker 部署

### Build and Run / 构建和运行

```bash
# Build image
docker build -t echomemo-backend .

# Run container
docker run -d \
  --name echomemo-api \
  -p 8000:8000 \
  --env-file .env \
  -v $(pwd)/uploads:/app/uploads \
  echomemo-backend
```

### Docker Compose / Docker Compose 部署

See main deployment guide: `/DEPLOYMENT.md`

参考主部署指南：`/DEPLOYMENT.md`

## Architecture / 架构

### Request Flow / 请求流程

```
User Upload Audio → FastAPI Endpoint → Background Task
                                              ↓
                              ┌───────────────┴───────────────┐
                              ↓                               ↓
                        STT Service                    Database
                       (Volcengine)                   (Save Memo)
                              ↓
                        LLM Service
                      (DeepSeek AI)
                              ↓
                        Update DB
```

### Background Processing / 后台处理

When audio is uploaded, the processing happens asynchronously:

音频上传后，处理异步进行：

1. Save audio file to disk / 保存音频文件
2. Create memo entry with status="processing" / 创建处理中的笔记记录
3. Trigger background task / 触发后台任务
4. STT transcribes audio to text / STT 转写音频
5. LLM analyzes transcription / LLM 分析转写文本
6. Update memo with results / 更新笔记结果

## Troubleshooting / 故障排除

### Common Issues / 常见问题

**Issue**: STT returns "Invalid audio format"
- **Cause**: Test audio file is not a valid audio format
- **Fix**: Use real audio files (WAV, MP3, M4A)

**问题**: STT 返回 "Invalid audio format"
- **原因**: 测试音频文件不是有效的音频格式
- **解决**: 使用真实的音频文件（WAV, MP3, M4A）

**Issue**: Database connection failed
- **Cause**: PostgreSQL not running or wrong credentials
- **Fix**: Check DATABASE_URL and ensure PostgreSQL is running

**问题**: 数据库连接失败
- **原因**: PostgreSQL 未运行或凭据错误
- **解决**: 检查 DATABASE_URL 并确保 PostgreSQL 正在运行

### Logging / 日志

Check application logs:

查看应用日志：

```bash
# Docker logs
docker logs echomemo-backend -f

# Local development
# Logs printed to stdout
```

## Security Notes / 安全提示

⚠️ **IMPORTANT / 重要**:

1. Never commit `.env` file to version control / 永远不要提交 `.env` 文件到版本控制
2. Use strong `SECRET_KEY` in production / 生产环境使用强密码作为 `SECRET_KEY`
3. Enable HTTPS in production / 生产环境启用 HTTPS
4. Rotate API keys regularly / 定期更换 API 密钥

## Contributing / 贡献

Contributions are welcome! Please follow these steps:

欢迎贡献！请遵循以下步骤：

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License / 许可证

MIT License

## Support / 支持

For issues and questions: / 如有问题，请访问：

- GitHub Issues: [EchoMemo Issues](https://github.com/myjnathan/EchoMemo/issues)
- Documentation: `/DEPLOYMENT.md`
