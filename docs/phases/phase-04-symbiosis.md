# Phase 4: The Symbiosis (共生) - Execution Plan

**Status**: 🌟 Vision
**Timeline**: 10-12 weeks
**Dependencies**: Phase 3 Complete

---

## 🎯 Phase Overview / 阶段概览

**Mission / 使命**: Redefine human-AI relationship as thought partners

**Core Philosophy / 核心理念**: Human-AI symbiosis, dialogic thinking / 人机共生，对话式思维

**Key Deliverables / 关键交付物**:
1. 💬 Generative dialogue / 生成式对话
2. 📚 Thought synthesis / 思维合成
3. 🪞 Digital twin export / 数字孪生导出

---

## Success Metrics / 成功指标

| Metric / 指标 | Target / 目标 |
|---------------|---------------|
| Dialogue Depth / 对话深度 | ≥30% users have 1+ deep dialogue/week |
| Export Usage / 导出使用率 | ≥20% users export monthly |
| User Satisfaction / 用户满意度 | ≥80% report AI is "thought partner" |

---

## Task Breakdown / 任务分解

### Epic 1: Generative Dialogue / 生成式对话

**Week 1-5 / 第1-5周**

#### Task 4.1.1: Conversational Memory System / 对话记忆系统

**File**: `backend/services/dialogue_memory.py`
**Estimated Time**: 7 days

**Requirements / 需求**:
- Remember all past conversations / 记住所有过去的对话
- Understand user's thinking patterns / 理解用户的思维模式
- Maintain consistent "AI personality" / 保持一致的"AI个性"

**Implementation / 实现**:
```python
from langchain.memory import (
    ConversationBufferMemory,
    VectorStoreMemory,
    CombinedMemory
)

class DialogueMemoryService:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.short_term = ConversationBufferMemory(k=10)  # Last 10 exchanges
        self.long_term = VectorStoreMemory(...)  # All conversations

    async def get_context(
        self,
        current_thought: ThoughtCapsule
    ) -> DialogueContext:
        """
        Gather relevant context from user's entire history
        从用户整个历史中收集相关上下文
        """
        # Find similar past thoughts
        similar_thoughts = await self._find_similar_thoughts(current_thought)

        # Get user's core themes
        core_themes = await self._extract_core_themes()

        # Understand evolution of ideas
        evolution = await self._track_idea_evolution()

        return DialogueContext(
            similar_thoughts=similar_thoughts,
            core_themes=core_themes,
            evolution=evolution
        )
```

#### Task 4.1.2: Socratic Question Generator / 苏格拉底式问题生成器

**File**: `backend/services/socratic_agent.py`
**Estimated Time**: 8 days

**Requirements / 需求**:
- Challenge assumptions / 挑战假设
- Offer counter-perspectives / 提供反向视角
- Ask "why" 5 levels deep / 5层深度追问"为什么"

**Prompt Engineering / 提示工程**:
```python
SOCRATIC_SYSTEM_PROMPT = """
You are a Socratic dialogue partner. Your role is to help the user
clarify their thinking through questioning, not to provide answers.

Principles:
1. Ask "why" to uncover deeper motivations
2. Challenge assumptions gently
3. Offer alternative perspectives
4. Connect to their past thoughts
5. Never give advice, only ask questions

When the user says something, first:
- Check if this relates to past conversations
- Identify assumptions
- Find potential blind spots

Then ask ONE clarifying question.
"""

class SocraticAgent:
    async def generate_response(
        self,
        user_input: str,
        dialogue_context: DialogueContext
    ) -> str:
        prompt = f"""
        User says: "{user_input}"

        Context from their history:
        - Similar past thoughts: {dialogue_context.similar_thoughts}
        - Core themes: {dialogue_context.core_themes}
        - Evolution: {dialogue_context.evolution}

        Generate ONE Socratic question to help them think deeper.
        """

        return await self.llm.generate(prompt)
```

---

### Epic 2: Thought Synthesis / 思维合成

**Week 5-8 / 第5-8周**

#### Task 4.2.1: Weekly "Intellectual Biography" / 每周"思想传记"

**File**: `backend/services/thought_synthesizer.py`
**Estimated Time**: 6 days

**Requirements / 需求**:
- Not a list, but a narrative / 不是列表，而是叙述
- Identify themes that emerged / 识别出现的主题
- Show evolution of ideas / 显示思想的演进

**Prompt Engineering / 提示工程**:
```python
WEEKLY_SYNTHESIS_PROMPT = """
Analyze this user's voice memos from the past week and write
their "Intellectual Biography" - a narrative summary of their
intellectual journey this week.

Structure:
1. The Week's Theme: What ONE concept kept recurring?
2. Three New Ideas: What fresh perspectives emerged?
3. Dialogue: How do these ideas talk to each other?
4. Evolution: How has their thinking changed?

Tone: Insightful, reflective, literary
Length: 500-800 words

Data: {weekly_memos}
"""

class ThoughtSynthesizer:
    async def generate_weekly_biography(self, user_id: str) -> str:
        week_memos = await self._get_week_memos(user_id)
        synthesis = await self.llm.generate(
            WEEKLY_SYNTHESIS_PROMPT.format(weekly_memos=week_memos)
        )
        return synthesis
```

#### Task 4.2.2: Idea Evolution Tracker / 思想演进追踪器

**File**: `backend/services/evolution_tracker.py`
**Estimated Time**: 5 days

**Requirements / 需求**:
- Trace how ideas change over time / 追踪想法如何随时间变化
- Visualize "idea family tree" / 可视化"想法家族树"
- Show contradictions and resolutions / 显示矛盾和解决

---

### Epic 3: Digital Twin Export / 数字孪生导出

**Week 8-10 / 第8-10周**

#### Task 4.3.1: Article Generator / 文章生成器

**File**: `backend/services/export_generator.py`
**Estimated Time**: 7 days

**Requirements / 需求**:
- Turn memos into blog-style article / 将备忘录转换为博客风格文章
- Maintain user's voice / 保持用户的声音
- Add narrative structure / 添加叙述结构

**Output Formats / 输出格式**:
1. **Markdown Blog Post** / Markdown博客文章
2. **PDF with formatting** / 带格式的PDF
3. **Audio podcast script** / 音频播客脚本

#### Task 4.3.2: Personal Chronicle / 个人编年史

**File**: `frontend/lib/features/export/widgets/chronicle_generator.dart`
**Estimated Time**: 5 days

**Requirements / 需求**:
- Organize by time periods / 按时间段组织
- Show major life events / 显示主要生活事件
- Include emotional arc / 包含情绪弧线

---

## Technical Architecture / 技术架构

### New Services / 新服务

```python
# backend/services/ai_agent.py
class AIDialogueAgent:
    """
    Main AI agent for Phase 4 dialogue
    第四阶段对话的主要AI代理
    """

    def __init__(self):
        self.memory = DialogueMemoryService()
        self.socratic_engine = SocraticAgent()
        self.synthesizer = ThoughtSynthesizer()
        self.personality = self._load_personality()

    async def process_message(
        self,
        user_message: str,
        user_id: str
    ) -> str:
        """
        Main dialogue loop
        主对话循环
        """
        # 1. Gather context
        context = await self.memory.get_context(user_message)

        # 2. Generate response
        response = await self.socratic_engine.generate_response(
            user_message,
            context
        )

        # 3. Remember this exchange
        await self.memory.add_exchange(user_message, response)

        return response
```

---

## Database Schema Updates / 数据库架构更新

```sql
CREATE TABLE dialogue_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    session_summary TEXT,
    total_exchanges INTEGER
);

CREATE TABLE dialogue_exchanges (
    id UUID PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES dialogue_sessions(id),
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    context_used JSONB,  -- What memories were accessed
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE thought_syntheses (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    synthesis_type VARCHAR(50) NOT NULL,  -- 'weekly', 'monthly', 'thematic'
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    content TEXT NOT NULL,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE export_jobs (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    export_type VARCHAR(50) NOT NULL,  -- 'article', 'chronicle', 'podcast'
    format VARCHAR(20) NOT NULL,  -- 'markdown', 'pdf', 'docx'
    status VARCHAR(20) DEFAULT 'pending',
    file_path VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Ethical Considerations / 伦理考虑

### AI Personality Guidelines / AI个性指南

1. **Never give medical or therapeutic advice** / 永远不要给出医疗或治疗建议
2. **Always maintain user autonomy** / 始终保持用户自主性
3. **Admit when confused** / 困惑时承认
4. **Don't manipulate emotions** / 不要操纵情绪
5. **Respect privacy** / 尊重隐私

### Safety Rails / 安全护栏

```python
SAFETY_GUIDELINES = """
1. If user expresses self-harm ideation:
   - Provide crisis resources
   - Do NOT attempt to "save" them
   - Encourage professional help

2. If user asks for life advice:
   - Offer perspectives, not answers
   - Ask "What do you think?"
   - Help them clarify values

3. If conversation becomes circular:
   - Gently shift direction
   - Summarize what's been covered
   - Suggest taking a break
"""
```

---

## Quick Resume / 快速恢复

**Prerequisites / 前置条件**: Phase 3 complete, extensive dialogue history
**First Task**: Task 4.1.1 (Conversational Memory System)
**Key Dependencies**: LLM with long context window (32K+ tokens)

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
