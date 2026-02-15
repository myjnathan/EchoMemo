# EchoMemo Quick Start Guide / 快速开始指南

**Last Updated**: 2025-02-15

---

## 🚀 For New Developers / 新开发者快速入门

Welcome to EchoMemo! This guide will get you up and running in 30 minutes.

欢迎来到EchoMemo！本指南将让您在30分钟内上手。

---

## ⚡ Quick Setup / 快速设置

### 1. Clone & Install / 克隆和安装 (5 minutes / 5分钟)

```bash
# Clone repository
git clone https://github.com/myjnathan/EchoMemo.git
cd EchoMemo

# Backend setup
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your API keys

# Frontend setup
cd ../frontend
flutter pub get
# Edit lib/services/api_service.dart to set your API endpoint
```

### 2. Run Backend / 运行后端 (2 minutes / 2分钟)

```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Check**: Visit http://localhost:8000/docs - You should see API documentation.

### 3. Run Frontend / 运行前端 (1 minute / 1分钟)

```bash
cd frontend
flutter run
```

**Check**: App should open with recording screen.

---

## 📚 Documentation Guide / 文档指南

### Where to Start / 从哪里开始

```
docs/
├── README.md                    # 📌 Start here! Documentation overview
├── DESIGN.md                    # 📖 Product philosophy & 4 phases
│
├── phases/                      # 📋 Phase execution plans
│   ├── phase-01-container.md    # 🚀 Current phase - Detailed tasks
│   ├── phase-02-weaver.md       # ⏳ Future - Knowledge network
│   ├── phase-03-mirror.md       # 🔮 Future - Self-reflection
│   └── phase-04-symbiosis.md    # 🌟 Vision - AI dialogue partner
│
├── architecture/                 # 🏗️ Technical architecture
│   ├── system-design.md          # System architecture & components
│   └── tech-roadmap.md           # Technology evolution timeline
│
└── tracking/                     # 📊 Progress tracking
    ├── progress-tracker.md      # 📍 Current status & tasks
    ├── decision-log.md           # 📝 Technical decisions
    └── milestone-checklist.md   # ✅ Phase milestones
```

### Reading Order / 阅读顺序

**First Day / 第一天**:
1. [README.md](docs/README.md) - Documentation overview / 文档概览
2. [DESIGN.md](docs/DESIGN.md) - Product vision (skim) / 产品愿景（浏览）
3. [progress-tracker.md](docs/tracking/progress-tracker.md) - Current status / 当前状态

**Before Starting Work / 开始工作前**:
1. [phase-01-container.md](docs/phases/phase-01-container.md) - Your tasks / 你的任务
2. [system-design.md](docs/architecture/system-design.md) - How system works / 系统如何工作

**When Blocked / 遇到阻碍时**:
1. [decision-log.md](docs/tracking/decision-log.md) - Past decisions / 过去的决策
2. [tech-roadmap.md](docs/architecture/tech-roadmap.md) - Technical choices / 技术选择

---

## 🎯 Your First Task / 你的第一个任务

### What to Do Now / 现在做什么

**Current Status**: Phase 1, Week 2
**Your First Task**: Task 1.1.2 - Pre-initialize audio recorder

**Steps / 步骤**:

1. **Open phase plan / 打开阶段计划**:
   ```
   docs/phases/phase-01-container.md
   ```

2. **Find Task 1.1.2 / 找到Task 1.1.2**:
   Search for "Task 1.1.2" in the document

3. **Read requirements / 阅读需求**:
   Understand what needs to be done

4. **Follow implementation / 跟随实施**:
   Copy the code examples provided

5. **Test your work / 测试你的工作**:
   Run the test cases provided

6. **Update progress / 更新进度**:
   Check the ✅ box in phase-01-container.md
   Update progress-tracker.md

---

## 🔄 Daily Workflow / 日常工作流程

### Start of Day / 一天开始

```bash
# 1. Pull latest code
git pull origin main

# 2. Check progress
cat docs/tracking/progress-tracker.md | grep "🚧 In Progress"

# 3. Start from your task
# Open phase-01-container.md, find unchecked task
```

### During Work / 工作中

```bash
# Work on your task
# Follow code examples in phase plan

# Commit frequently
git add .
git commit -m "feat: implement pre-initialized audio recorder"
git push
```

### End of Day / 一天结束

```bash
# Update progress-tracker.md
# 1. Mark completed tasks as ✅
# 2. Add entry to Daily Progress Log
# 3. Update "Next Task" section

# Commit documentation
git add docs/
git commit -m "docs: update progress"
git push
```

---

## 🚨 When You're Blocked / 当你被阻碍时

### Scenario 1: Task is unclear / 任务不清楚

**Solution / 解决方案**:
1. Check [phase-01-container.md](../phases/phase-01-container.md) for detailed requirements
2. Check [system-design.md](../architecture/system-design.md) for technical context
3. Check [decision-log.md](../tracking/decision-log.md) for related decisions

### Scenario 2: Technical issue / 技术问题

**Solution / 解决方案**:
1. Check [tech-roadmap.md](../architecture/tech-roadmap.md) for alternatives
2. Check [decision-log.md](../tracking/decision-log.md) for similar issues
3. Ask in team chat / 在团队聊天中询问

### Scenario 3: You've been away for a while / 你离开了一段时间

**Solution / 解决方案**:
1. Read [progress-tracker.md](../tracking/progress-tracker.md) - "Current Status" section
2. Read [decision-log.md](../tracking/decision-log.md) - Recent decisions
3. Find next unchecked task in [phase-01-container.md](../phases/phase-01-container.md)
4. Resume from there / 从那里继续

---

## 📊 Key Metrics to Watch / 要关注的关键指标

### Phase 1 Success Metrics / 第一阶段成功指标

- ⚡ **App Launch Time**: Target ≤1.5s
- 🎤 **Recording Ready**: Target <0.5s after launch
- 📝 **Transcription Latency**: Target <300ms
- 😊 **User Satisfaction**: Target ≥80% positive

### How to Measure / 如何测量

```bash
# Launch time
# Run app with performance monitoring
# Check: flutter run --profile

# Transcription latency
# Check backend logs for timestamp

# User satisfaction
# See feedback in progress-tracker.md
```

---

## 🔧 Useful Commands / 有用的命令

### Backend / 后端

```bash
# Run with hot reload
uvicorn main:app --reload

# Run tests
pytest

# Check database
python -c "from database import engine; print('OK')"

# View logs
tail -f logs/echomemo.log
```

### Frontend / 前端

```bash
# Run with hot reload
flutter run

# Run on specific device
flutter run -d ios
flutter run -d android

# Run tests
flutter test

# Build for production
flutter build apk --release
```

### Git / Git

```bash
# Update docs
git add docs/
git commit -m "docs: update progress"

# Push changes
git push origin main

# Create feature branch
git checkout -b feature/phase-1-task-1.2.1
```

---

## 📞 Getting Help / 获取帮助

### Resources / 资源

- **Product Questions**: See [DESIGN.md](../DESIGN.md)
- **Technical Questions**: See [system-design.md](../architecture/system-design.md)
- **Task Questions**: See [phase-01-container.md](../phases/phase-01-container.md)
- **Progress Questions**: See [progress-tracker.md](../tracking/progress-tracker.md)

### Team Communication / 团队沟通

- **Daily Standup**: Share progress from [progress-tracker.md](../tracking/progress-tracker.md)
- **Blockers**: Report immediately, don't wait
- **Decisions**: Document in [decision-log.md](../tracking/decision-log.md)

---

## ✅ Checklist Before Starting Work / 开始工作前的检查清单

- [ ] Read [DESIGN.md](../DESIGN.md) (skim is OK / 浏览即可)
- [ ] Read [progress-tracker.md](../tracking/progress-tracker.md) "Current Status"
- [ ] Find your next task in [phase-01-container.md](../phases/phase-01-container.md)
- [ ] Check [decision-log.md](../tracking/decision-log.md) for recent decisions
- [ ] Pull latest code: `git pull`
- [ ] Install dependencies: `flutter pub get` and `pip install -r requirements.txt`

---

## 🎉 You're Ready! / 准备好了！

You now have everything you need to start contributing to EchoMemo.

您现在拥有开始为EchoMemo做出贡献所需的一切。

**Next step**: Find your first task in [phase-01-container.md](../phases/phase-01-container.md) and start building! / **下一步**：在 [phase-01-container.md](../phases/phase-01-container.md) 中找到您的第一个任务并开始构建！

---

**Need Help? / 需要帮助？**
- See [Documentation README](../README.md)
- Check [Progress Tracker](../tracking/progress-tracker.md)

**Happy Coding! / 祝编码愉快！** 🚀
