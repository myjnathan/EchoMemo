# Phase 2: The Weaver (织网) - Execution Plan

**Status**: 📋 Planned
**Timeline**: 6-8 weeks
**Priority**: High
**Dependencies**: Phase 1 Complete

---

## 🎯 Phase Overview / 阶段概览

**Mission / 使命**: Transform fragmented records into structured knowledge networks

**Core Philosophy / 核心理念**: Emerge order from chaos, discover hidden connections between thoughts

**Key Deliverables / 关键交付物**:
1. 🧠 Intelligent summarization & structuring / 智能摘要与结构化
2. 🔍 Semantic cross-temporal associations / 语义跨时空关联
3. 🎨 Visual infinite canvas / 可视化无限画布

---

## Success Metrics / 成功指标

| Metric / 指标 | Target / 目标 |
|---------------|---------------|
| Association Discovery Rate / 关联发现率 | 5-10 valuable associations/week |
| Organization Participation / 整理参与度 | ≥40% of active users |
| User Retention / 用户留存 | ≥70% MAU after 3 months |

---

## Technical Architecture / 技术架构

### New Backend Services / 新的后端服务

```python
# backend/services/semantic_analysis.py
class SemanticAnalysisService:
    """Analyzes semantic relationships between thoughts"""

    async def find_associations(
        self,
        capsule_id: str,
        user_id: str
    ) -> List[SemanticAssociation]:
        """
        Find semantically related thoughts
        查找语义相关的想法

        Returns:
            List of associations with confidence scores
        """

    async def generate_summary(
        self,
        capsule_id: str
    ) -> ThoughtSummary:
        """
        Generate intelligent summary
        生成智能摘要
        """

# backend/services/knowledge_graph.py
class KnowledgeGraphService:
    """Builds and maintains thought relationship graph"""

    async def build_graph(self, user_id: str) -> KnowledgeGraph:
        """
        Construct semantic network of user's thoughts
        构建用户想法的语义网络
        """

    async def find_shortest_path(
        self,
        from_capsule: str,
        to_capsule: str
    ) -> List[ThoughtCapsule]:
        """
        Find connecting thoughts between two capsules
        找到两个胶囊之间的连接想法
        """
```

### Frontend Architecture / 前端架构

```dart
// lib/features/weaver/
lib/features/weaver/
├── infinite_canvas/
│   ├── widgets/
│   │   ├── canvas_painter.dart         // Custom canvas drawing
│   │   ├── capsule_node.dart           // Draggable capsule nodes
│   │   ├── connection_line.dart        // Visual connections
│   │   └── zoom_pan_handler.dart       // Canvas navigation
│   └── controllers/
│       └── canvas_controller.dart      // Canvas state management
├── associations/
│   ├── widgets/
│   │   ├── association_card.dart       // Show related thoughts
│   │   └── connection_strength.dart    // Visual confidence indicator
│   └── controllers/
│       └── association_controller.dart // Manage associations
└── smart_summary/
    ├── widgets/
    │   └── summary_view.dart            // Structured summary display
    └── controllers/
        └── summary_controller.dart      // Summary generation
```

---

## Task Breakdown / 任务分解

### Epic 1: Intelligent Summarization / 智能摘要

**Week 1-3 / 第1-3周**

#### Task 2.1.1: Core Summary Engine / 核心摘要引擎

**File**: `backend/services/summarization.py`
**Estimated Time**: 5 days

**Requirements / 需求**:
- Extract key points from 5-min rambling / 从5分钟的碎碎念中提取关键点
- Identify logical structure ("first", "second", "but", "so") / 识别逻辑结构
- Generate 1-sentence core message / 生成1句话核心信息

**Implementation / 实现**:
```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains.summarize import load_summarize_chain

class ThoughtSummarizer:
    def __init__(self, llm_service):
        self.llm = llm_service
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200
        )

    async def generate_core_message(self, transcription: str) -> str:
        """
        Extract the "what user really wants to say"
        提取"用户真正想说什么"
        """
        prompt = f"""
        Analyze this voice transcription and identify:
        1. What is the user really trying to express?
        2. What is the core message in ONE sentence?

        Transcription: {transcription}

        Output format: JSON {{"core_message": "..."}}
        """

        result = await self.llm.analyze(prompt)
        return result["core_message"]

    async def extract_key_points(self, transcription: str) -> List[str]:
        """Extract 3-5 key points / 提取3-5个关键点"""
        # Implementation here
        pass
```

#### Task 2.1.2: Logical Structure Detection / 逻辑结构检测

**File**: `backend/services/structure_analyzer.py`
**Estimated Time**: 4 days

**Requirements / 需求**:
- Detect numbering ("first", "second") / 检测编号
- Detect contrast ("but", "however") / 检测转折
- Detect causation ("because", "so") / 检测因果

---

### Epic 2: Semantic Associations / 语义关联

**Week 3-5 / 第3-5周**

#### Task 2.2.1: Embedding-Based Similarity / 基于嵌入的相似度

**File**: `backend/services/embedding_service.py`
**Estimated Time**: 5 days

**Tech Stack / 技术栈**:
- OpenAI text-embedding-3-small (cheaper, faster) / OpenAI嵌入模型
- FAISS for vector similarity search / FAISS向量搜索
- Redis for caching embeddings / Redis缓存嵌入

**Implementation / 实现**:
```python
import openai
import faiss
import numpy as np

class EmbeddingService:
    def __init__(self):
        self.index = faiss.IndexFlatL2(1536)  # OpenAI embedding dimension
        self.capsule_ids = []

    async def index_capsule(self, capsule_id: str, text: str):
        """Generate and store embedding / 生成并存储嵌入"""
        embedding = await self.generate_embedding(text)
        self.index.add(np.array([embedding]))
        self.capsule_ids.append(capsule_id)

    async def find_similar(
        self,
        capsule_id: str,
        threshold: float = 0.75
    ) -> List[Tuple[str, float]]:
        """Find semantically similar capsules / 查找语义相似的胶囊"""
        # Implementation
        pass
```

#### Task 2.2.2: Manual Association Tool / 手动关联工具

**File**: `frontend/lib/features/weaver/widgets/association_tool.dart`
**Estimated Time**: 3 days

**UI Requirements / UI需求**:
- Drag-and-drop to connect capsules / 拖放连接胶囊
- Visual strength indicator / 视觉强度指示器
- Undo/redo support / 支持撤销/重做

---

### Epic 3: Infinite Canvas / 无限画布

**Week 5-7 / 第5-7周**

#### Task 2.3.1: Canvas Core / 画布核心

**File**: `frontend/lib/features/weaver/infinite_canvas/widgets/canvas_painter.dart`
**Estimated Time**: 7 days

**Requirements / 需求**:
- Infinite pan & zoom / 无限平移和缩放
- 60 FPS rendering / 60帧渲染
- Support 1000+ nodes / 支持1000+节点

**Implementation / 实现**:
```dart
class InfiniteCanvas extends StatefulWidget {
  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: false,  // Allow infinite canvas
      minScale: 0.1,
      maxScale: 5.0,
      child: CustomPaint(
        painter: CanvasPainter(capsules: capsules),
        size: Size.infinite,
      ),
    );
  }
}
```

#### Task 2.3.2: Multiple View Modes / 多种视图模式

**File**: `frontend/lib/features/weaver/infinite_canvas/widgets/view_switcher.dart`
**Estimated Time**: 4 days

**Modes / 模式**:
1. **Mind Map / 思维导图**: Radial layout / 放射状布局
2. **List / 列表**: Organized by tags / 按标签组织
3. **Matrix / 矩阵**: 2D axes (importance vs urgency) / 二维轴（重要性vs紧急性）
4. **Timeline / 时间线**: Chronological order / 时间顺序

---

## Database Schema Updates / 数据库架构更新

```sql
-- New tables for Phase 2

CREATE TABLE thought_summaries (
    id UUID PRIMARY KEY,
    capsule_id UUID NOT NULL REFERENCES thought_capsules(id) ON DELETE CASCADE,
    core_message TEXT NOT NULL,
    key_points JSONB,  -- Array of key points
    logical_structure JSONB,  -- Detected structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(capsule_id)
);

CREATE TABLE semantic_associations (
    id UUID PRIMARY KEY,
    source_capsule_id UUID NOT NULL REFERENCES thought_capsules(id),
    target_capsule_id UUID NOT NULL REFERENCES thought_capsules(id),
    similarity_score DECIMAL(4, 3) NOT NULL,
    association_type VARCHAR(50) NOT NULL,  -- 'semantic', 'manual', 'temporal'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_confirmed BOOLEAN DEFAULT FALSE,

    UNIQUE(source_capsule_id, target_capsule_id),
    CHECK (source_capsule_id != target_capsule_id)
);

CREATE INDEX idx_associations_source ON semantic_associations(source_capsule_id);
CREATE INDEX idx_associations_similarity ON semantic_associations(similarity_score DESC)
  WHERE user_confirmed = TRUE;

CREATE TABLE canvas_layouts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    layout_name VARCHAR(255) NOT NULL,
    layout_data JSONB NOT NULL,  -- Node positions, connections
    view_mode VARCHAR(50) NOT NULL,  -- 'mindmap', 'list', 'matrix', 'timeline'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_default BOOLEAN DEFAULT FALSE
);
```

---

## Quick Resume / 快速恢复

**Last Task**: Check [progress-tracker.md](../tracking/progress-tracker.md)
**Next Task**: Review Epic 1, Task 2.1.1
**Blockers**: Ensure Phase 1 is complete

---

**Document Version**: v1.0.0
**Last Updated**: 2025-02-15
