# Technical Decision Log / 技术决策记录

**Last Updated**: 2025-02-15

This document records all significant technical decisions made during EchoMemo development. Each decision includes the context, options considered, rationale, and consequences.

本文档记录EchoMemo开发过程中做出的所有重要技术决策。每个决策包括背景、考虑的选项、理由和后果。

---

## Decision Template / 决策模板

```markdown
### D-XXX: [Decision Title / 决策标题]

**Date / 日期**: YYYY-MM-DD
**Status / 状态**: Proposed | Accepted | Rejected | Deprecated
**Decision Maker / 决策者**: [Name]
**Owner / 负责人**: [Name]

**Context / 背景**:
[What problem are we solving?]

**Considered Options / 考虑的选项**:
1. **Option A**: [Description]
   - Pros: [优点]
   - Cons: [缺点]
2. **Option B**: [Description]
   - Pros: [优点]
   - Cons: [缺点]

**Decision / 决策**:
[Choose Option A/B]

**Rationale / 理由**:
[Why this decision?]

**Consequences / 后果**:
- Positive: [正面影响]
- Negative: [负面影响]
- Risks: [风险]

**Related Decisions / 相关决策**:
- Link to D-XXX
```

---

## Decision Log / 决策日志

### D-001: Choose Flutter for Cross-Platform Development

**Date / 日期**: 2025-02-10
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Tech Lead

**Context / 背景**:
Need to build mobile app for iOS and Android with limited development resources.

需要在资源有限的情况下为iOS和Android构建移动应用。

**Considered Options / 考虑的选项**:

1. **Flutter**: Cross-platform, single codebase, 60 FPS rendering
   - Pros: Fast development, native performance, great custom widgets
   - Cons: Larger app size, smaller community than React Native

2. **React Native**: JavaScript-based, large community
   - Pros: Huge ecosystem, web developers can contribute
   - Cons: Slower performance, complex navigation, debugging issues

3. **Native (Swift + Kotlin)**: Best performance, worst development speed
   - Pros: Perfect platform integration
   - Cons: 2x development time, need 2 developers

**Decision / 决策**:
✅ **Choose Flutter**

**Rationale / 理由**:
- Single developer can maintain both platforms
- Custom animation support needed for waveform visualization
- Better performance for real-time audio processing
- Hot reload speeds up development

**Consequences / 后果**:
- ✅ Can ship to both platforms simultaneously
- ⚠️ App size ~50MB (acceptable)
- ✅ Easy to add macOS desktop support later
- ⚠️ Learning curve for Dart language

---

### D-002: Use FastAPI for Backend with WebSocket Support

**Date / 日期**: 2025-02-10
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Backend Lead

**Context / 背景**:
Need real-time streaming transcription (Phase 1 requirement: <300ms latency).

需要实时流式转译（第一阶段要求：<300ms延迟）。

**Considered Options / 考虑的选项**:

1. **FastAPI + WebSocket**: Python-based, async, great WebSocket support
   - Pros: Native async/await, auto API docs, easy to learn
   - Cons: GIL limitation for CPU-intensive tasks

2. **Django + Channels**: Mature, but heavier
   - Pros: Stable, many plugins
   - Cons: Slower, more complex setup

3. **Node.js + Express**: JavaScript-based, fast
   - Pros: Fast I/O, no GIL
   - Cons: Callback hell (without async/await), less type safety

**Decision / 决策**:
✅ **Choose FastAPI + WebSocket**

**Rationale / 理由**:
- Async/await syntax perfect for streaming
- Auto-generated OpenAPI docs (/docs endpoint)
- Python ecosystem (ML libraries, STT services)
- Easy to integrate with Python ML models

**Consequences / 后果**:
- ✅ Excellent streaming performance
- ✅ Easy LLM integration (both written in Python)
- ⚠️ May need Gunicorn/Uvicorn workers for production

---

### D-003: Store Audio Files Locally with Device Encryption

**Date / 日期**: 2025-02-12
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Security Lead

**Context / 背景**:
User privacy is paramount. Product philosophy: "This is your thought, we just guard it."

用户隐私至关重要。产品哲学："这是你的思想，我们只是保管者。"

**Considered Options / 考虑的选项**:

1. **Local encrypted storage (AES-256)**: Zero-knowledge architecture
   - Pros: Maximum privacy, no server storage cost, GDPR-compliant
   - Cons: Can't sync across devices, lost if device lost

2. **Cloud storage with encryption**: Centralized, encrypted on server
   - Pros: Cross-device sync, backup
   - Cons: Server cost, trust required, data breach risk

3. **Hybrid**: Local default, optional cloud backup
   - Pros: User choice, best of both
   - Cons: More complex implementation

**Decision / 决定**:
✅ **Choose Local encrypted storage (with optional cloud backup in Phase 2)**

**Rationale / 理由**:
- Aligns with "Privacy First" principle
- Zero infrastructure cost for Phase 1
- Builds user trust
- Can add sync later (Phase 2: "Weaver" features)

**Consequences / 后果**:
- ✅ No server-side audio storage costs
- ✅ Cannot leak user audio (we never have it)
- ⚠️ Users must manually back up
- ✅ Immediate trust from privacy-conscious users

---

### D-004: Implement Custom Waveform Visualization (Not Library)

**Date / 日期**: 2025-02-13
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Frontend Lead

**Context / 背景**:
Need real-time audio waveform synced with transcription. Target: 60 FPS.

需要与转译同步的实时音频波形。目标：60 FPS。

**Considered Options / 考虑的选项**:

1. **Custom implementation using CustomPainter**: Full control, optimized
   - Pros: Lightweight (no library), exact customization
   - Cons: More development time

2. **audio_waveforms package**: Ready-made solution
   - Pros: Quick implementation
   - Cons: Limited customization, larger app size

3. **waveform package**: Alternative library
   - Pros: Good features
   - Cons: Not actively maintained

**Decision / 决定**:
✅ **Choose Custom implementation using CustomPainter**

**Rationale / 理由**:
- Need specific visual style (calm, flowing, not techy)
- Performance critical (60 FPS target)
- Sync with transcription requires custom logic
- Keep app size small

**Consequences / 后果**:
- ✅ Perfect visual control
- ✅ Optimized performance
- ⚠️ 2-3 days development time
- ✅ Smaller app size (~500KB vs ~2MB with library)

---

### D-005: Use Volcengine STT (Chinese) with OpenAI Whisper Fallback

**Date / 日期**: 2025-02-14
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Tech Lead

**Context / 背景**:
Need STT for Chinese speech recognition with <300ms latency.

需要中文语音识别，延迟<300ms。

**Considered Options / 考虑的选项**:

1. **Volcengine (ByteDance)**: Best for Chinese, affordable
   - Pros: Optimized for Chinese, low latency ($0.05/min)
   - Cons: China-specific, requires API keys

2. **OpenAI Whisper**: Best accuracy worldwide
   - Pros: Excellent accuracy, many language support
   - Cons: Higher latency (~500ms), more expensive ($0.006/min)

3. **Google Cloud Speech-to-Text**: Good balance
   - Pros: Good accuracy, moderate price
   - Cons: Requires Google Cloud setup

**Decision / 决定**:
✅ **Choose Volcengine as primary, OpenAI Whisper as fallback**

**Rationale / 理由**:
- Volcengine fastest for Chinese (<300ms achievable)
- OpenAI Whisper as backup if Volcengine fails
- Reduces vendor lock-in
- Can route based on user preference

**Consequences / 后果**:
- ✅ Best latency for Chinese users
- ✅ Cost-effective ($0.05/min)
- ⚠️ Need to implement two STT services
- ✅ Automatic fallback improves reliability

---

### D-006: Database Schema Design for Time-Series Data

**Date / 日期**: 2025-02-14
**Status / 状态**: ✅ Accepted
**Decision Maker / 决策者**: Backend Lead

**Context / 背景**:
Need to store time-series thought capsules with efficient querying.

需要存储时间序列思想胶囊并高效查询。

**Considered Options / 考虑的选项**:

1. **PostgreSQL with BRIN indexes**: Optimized for time-series
   - Pros: ACID compliance, reliable, great indexing
   - Cons: Requires indexing strategy

2. **InfluxDB**: Purpose-built time-series database
   - Pros: Perfect for time-series, efficient
   - Cons: Overkill, no relational features, another DB to manage

3. **MongoDB**: Document-based, flexible
   - Pros: Flexible schema, easy scaling
   - Cons: No ACID, harder to maintain data integrity

**Decision / 决定**:
✅ **Choose PostgreSQL with BRIN indexes**

**Rationale / 理由**:
- Already using PostgreSQL for user data
- BRIN indexes perfect for time-series (small, fast)
- Need relational features for Phase 2-4 (associations, dialogue)
- Mature, well-understood technology

**Consequences / 后果**:
- ✅ Single database for all data
- ✅ Efficient time-series queries
- ✅ Easy to add relational features later
- ⚠️ Need to design indexes carefully

**Implementation Details / 实施细节**:
```sql
-- BRIN index for time-series
CREATE INDEX idx_capsules_created_brin
ON thought_capsules USING BRIN (created_at);

-- Composite index for user queries
CREATE INDEX idx_capsules_user_created
ON thought_capsules (user_id, created_at DESC);
```

---

## Decision Categories / 决策类别

### Architecture / 架构
- D-001: Flutter for cross-platform
- D-002: FastAPI backend with WebSocket
- D-006: PostgreSQL with BRIN indexes

### Security / 安全
- D-003: Local encrypted storage

### UX/UI / 用户体验
- D-004: Custom waveform visualization

### Integration / 集成
- D-005: Volcengine STT with OpenAI fallback

---

## Pending Decisions / 待定决策

### PD-001: Hosting Infrastructure for Phase 2

**Context / 背景**:
Phase 2 will need vector database (FAISS) and cache (Redis). Where to host?

**Options / 选项**:
- AWS (ElastiCache + EC2)
- Google Cloud (Memorystore + Compute Engine)
- DigitalOcean (Managed Redis + Droplets)
- Self-hosted (VPS with Docker)

**Due Date / 截止日期**: End of Phase 1 (Week 6)

---

### PD-002: LLM Provider for Phase 4 Dialogue

**Context / 背景**:
Phase 4 requires long-context LLM (32K+ tokens) for dialogue memory.

**Options / 选项**:
- OpenAI GPT-4 Turbo (128K context, expensive)
- Anthropic Claude 3 Opus (200K context, very expensive)
- DeepSeek (16K context, cheap, may upgrade to 32K)
- Local LLaMA (free, needs GPU)

**Due Date / 截止日期**: Phase 3 (Week 8-10)

---

## Decision Reversals / 决策撤销

### Reversed Decisions / 撤销的决策

None yet. We've made good decisions!

目前还没有。我们做出了很好的决策！

**Process to reverse a decision / 撤销决策的流程**:
1. Document why original decision is no longer valid / 记录为什么原决定不再有效
2. Propose new option with rationale / 提出新选项和理由
3. Get team approval / 获得团队批准
4. Update this document with "Status: Deprecated" / 更新此文档状态为"已弃用"
5. Create new decision entry / 创建新决策条目

---

## Related Documents / 相关文档

- [Progress Tracker](./progress-tracker.md)
- [Technical Roadmap](../architecture/tech-roadmap.md)
- [Phase 1 Plan](../phases/phase-01-container.md)

---

## How to Add a Decision / 如何添加决策

1. **Copy template** / 复制模板 from the top of this document / 从本文档顶部
2. **Assign decision ID** / 分配决策ID (e.g., D-007)
3. **Fill in all sections** / 填写所有章节
4. **Update status** to "Accepted" / 更新状态为"已接受"
5. **Link related decisions** / 链接相关决策
6. **Communicate to team** / 向团队传达

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
**Next Review**: Weekly during development
