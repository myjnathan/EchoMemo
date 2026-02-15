# Phase 3: The Mirror (镜像) - Execution Plan

**Status**: 🔮 Future
**Timeline**: 8-10 weeks
**Dependencies**: Phase 2 Complete

---

## 🎯 Phase Overview / 阶段概览

**Mission / 使命**: Help users "see" their emotional and cognitive patterns

**Core Philosophy / 核心理念**: Metacognition - thinking about thinking / 元认知 - 对思考的思考

**Key Deliverables / 关键交付物**:
1. 🌤️ Emotional weather station / 情绪气象站
2. 🔄 Echo mechanism (time-travel) / 回响机制（时光倒流）
3. 💭 Guided reflection (CBT-based) / 引导式反思（基于CBT）

---

## Success Metrics / 成功指标

| Metric / 指标 | Target / 目标 |
|---------------|---------------|
| Self-Insight Depth / 自我洞察深度 | ≥70% users report new insights |
| Emotional Regulation / 情绪调节效果 | ≥70% report improved mood |
| Weekly Reflection Engagement / 周反思参与度 | ≥50% active users |

---

## Task Breakdown / 任务分解

### Epic 1: Emotional Weather Station / 情绪气象站

**Week 1-4 / 第1-4周**

#### Task 3.1.1: Voice Emotion Detection / 语音情绪检测

**File**: `backend/services/emotion_analyzer.py`
**Estimated Time**: 7 days

**Requirements / 需求**:
- Analyze voice tone (pitch, speed, pauses) / 分析语调（音高、语速、停顿）
- Detect sentiment from text / 从文本检测情感
- Combine audio + text for accuracy / 结合音频+文本提高准确性

**Tech Stack / 技术栈**:
- librosa for audio analysis / librosa音频分析
- VADER for sentiment / VADER情感分析
- Custom ML model for voice emotion / 自定义语音情绪ML模型

**Implementation / 实现**:
```python
import librosa
import numpy as np
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

class EmotionAnalyzer:
    def __init__(self):
        self.sentiment_analyzer = SentimentIntensityAnalyzer()

    async def analyze_emotion(
        self,
        audio_path: str,
        transcription: str
    ) -> EmotionReport:
        """
        Comprehensive emotion analysis
        综合情绪分析
        """
        # Audio features
        audio_features = await self._extract_audio_features(audio_path)

        # Text sentiment
        text_sentiment = self.sentiment_analyzer.polarity_scores(transcription)

        # Combine
        emotion = await self._combine_analysis(audio_features, text_sentiment)

        return EmotionReport(
            primary_emotion=emotion.primary,
            intensity=emotion.intensity,
            confidence=emotion.confidence
        )
```

#### Task 3.1.2: Emotional Timeline Visualization / 情绪时间线可视化

**File**: `frontend/lib/features/mirror/widgets/emotion_timeline.dart`
**Estimated Time**: 5 days

**UI Requirements / UI需求**:
- Color-coded by emotion / 按情绪颜色编码
- Show patterns (weekly, monthly) / 显示模式（每周、每月）
- Highlight triggers / 高亮触发因素

---

### Epic 2: Echo Mechanism / 回响机制

**Week 4-6 / 第4-6周**

#### Task 3.2.1: "On This Day" Notification / "历史上的今天"通知

**File**: `backend/services/echo_service.py`
**Estimated Time**: 4 days

**Requirements / 需求**:
- Daily notification at 9 PM / 晚上9点每日通知
- Show capsule from 1 year ago / 显示1年前的胶囊
- Ask "How do you feel about this now?" / 问"你现在对此感觉如何？"

#### Task 3.2.2: Space Decay Visualization / 空间衰减可视化

**File**: `frontend/lib/features/mirror/widgets/fading_capsule.dart`
**Estimated Time**: 3 days

**Requirements / 需求**:
- Unclicked capsules fade over time / 未点击的胶囊随时间淡化
- Size reduces based on recall frequency / 根据回忆频率缩小尺寸
- Visual metaphor for memory decay / 记忆衰减的视觉隐喻

**Implementation / 实现**:
```dart
class FadingCapsule extends StatelessWidget {
  final ThoughtCapsule capsule;
  final DateTime lastViewed;

  double get _opacity {
    final daysSinceViewed = DateTime.now().difference(lastViewed).inDays;
    return max(0.3, 1.0 - (daysSinceViewed * 0.05));
  }

  double get _scale {
    final viewCount = capsule.viewCount;
    return max(0.6, min(1.0, 1.0 - (viewCount * 0.02)));
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: Transform.scale(
        scale: _scale,
        child: CapsuleCard(capsule: capsule),
      ),
    );
  }
}
```

---

### Epic 3: Guided Reflection / 引导式反思

**Week 6-8 / 第6-8周**

#### Task 3.3.1: CBT-Based Question Generator / 基于CBT的问题生成器

**File**: `backend/services/reflection_guide.py`
**Estimated Time**: 6 days

**Requirements / 需求**:
- Detect negative emotions (anxiety, anger, sadness) / 检测负面情绪
- Generate Socratic questions / 生成苏格拉底式问题
- Guide cognitive restructuring / 引导认知重构

**Prompt Engineering / 提示工程**:
```python
CBT_PROMPTS = {
    "anxiety": [
        "What specific aspect of this situation feels most overwhelming?",
        "What's the evidence that this will happen?",
        "What's the evidence that it won't happen?",
        "If the worst did happen, what could you do?",
    ],
    "anger": [
        "What boundary was crossed?",
        "What value of yours was violated?",
        "Is this anger protecting you from something else?",
    ],
    "sadness": [
        "What did you lose?",
        "What can you learn from this?",
        "What small step can you take today?",
    ]
}
```

#### Task 3.3.2: Reflection Journal UI / 反思日记界面

**File**: `frontend/lib/features/mirror/screens/reflection_screen.dart`
**Estimated Time**: 5 days

**UI Flow / UI流程**:
1. Show detected emotion / 显示检测到的情绪
2. Present guiding question / 提出引导性问题
3. User responds with voice or text / 用户语音或文字回复
4. System reflects back / 系统回应
5. Save as reflection entry / 保存为反思记录

---

## Database Schema Updates / 数据库架构更新

```sql
CREATE TABLE emotion_reports (
    id UUID PRIMARY KEY,
    capsule_id UUID NOT NULL REFERENCES thought_capsules(id),
    primary_emotion VARCHAR(50) NOT NULL,
    emotion_intensity DECIMAL(4, 3) NOT NULL,  -- 0.0 to 1.0
    confidence DECIMAL(4, 3) NOT NULL,
    audio_features JSONB,  -- pitch, tempo, pauses
    text_sentiment JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE reflection_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    capsule_id UUID REFERENCES thought_capsules(id),  -- Can be null
    trigger_emotion VARCHAR(50),
    question_asked TEXT NOT NULL,
    user_response TEXT,
    system_reflection TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE echo_notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    capsule_id UUID NOT NULL REFERENCES thought_capsules(id),
    notification_date DATE NOT NULL,
    user_response TEXT,  -- "How do you feel now?"
    was_helpful BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, notification_date)
);
```

---

## Quick Resume / 快速恢复

**Prerequisites / 前置条件**: Phase 2 complete
**First Task**: Task 3.1.1 (Voice Emotion Detection)
**Key Dependencies**: Emotion ML model training

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
