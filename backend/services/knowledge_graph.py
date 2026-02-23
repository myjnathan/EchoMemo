"""
知识图谱服务
构建和管理笔记之间的思维网络
"""
import logging
from typing import List, Dict, Set, Tuple, Optional
from dataclasses import dataclass, field
from collections import defaultdict, deque
import numpy as np

logger = logging.getLogger(__name__)


@dataclass
class GraphNode:
    """图节点：表示一个笔记"""
    id: int
    transcription: str
    summary: Optional[str] = None
    tags: List[str] = field(default_factory=list)
    topics: List[str] = field(default_factory=list)  # 从structured_summary提取
    mood_score: Optional[float] = None
    created_at: str = ""
    # 可选的布局信息
    x: Optional[float] = None
    y: Optional[float] = None

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "transcription": self.transcription,
            "summary": self.summary,
            "tags": self.tags,
            "topics": self.topics,
            "mood_score": self.mood_score,
            "created_at": self.created_at,
            "x": self.x,
            "y": self.y,
        }


@dataclass
class GraphEdge:
    """图边：表示笔记之间的关系"""
    source: int  # 源节点ID
    target: int  # 目标节点ID
    weight: float  # 关系强度 (0-1)
    relation_type: str  # 关系类型：semantic, tag, temporal, mood
    metadata: dict = field(default_factory=dict)  # 额外信息

    def to_dict(self) -> dict:
        return {
            "source": self.source,
            "target": self.target,
            "weight": self.weight,
            "relation_type": self.relation_type,
            "metadata": self.metadata,
        }


class KnowledgeGraph:
    """知识图谱：管理节点和边，提供图算法"""

    def __init__(self):
        self.nodes: Dict[int, GraphNode] = {}
        self.edges: Dict[int, Dict[int, GraphEdge]] = defaultdict(dict)  # adjacency list
        self.relation_types: Set[str] = set()

    def add_node(self, node: GraphNode):
        """添加节点"""
        self.nodes[node.id] = node

    def add_edge(self, edge: GraphEdge):
        """添加边（无向图）"""
        self.edges[edge.source][edge.target] = edge
        self.edges[edge.target][edge.source] = GraphEdge(
            source=edge.target,
            target=edge.source,
            weight=edge.weight,
            relation_type=edge.relation_type,
            metadata=edge.metadata
        )
        self.relation_types.add(edge.relation_type)

    def get_neighbors(self, node_id: int) -> List[Tuple[int, GraphEdge]]:
        """获取节点的所有邻居"""
        if node_id not in self.edges:
            return []
        return [(target, self.edges[node_id][target]) for target in self.edges[node_id]]

    def get_degree(self, node_id: int) -> int:
        """获取节点的度数（连接数）"""
        return len(self.edges.get(node_id, {}))

    def shortest_path(self, start: int, end: int) -> Optional[List[int]]:
        """
        使用BFS找到两个节点之间的最短路径
        返回节点ID列表，如果不存在路径则返回None
        """
        if start not in self.nodes or end not in self.nodes:
            return None

        if start == end:
            return [start]

        queue = deque([[start]])
        visited = {start}

        while queue:
            path = queue.popleft()
            node = path[-1]

            for neighbor, _ in self.get_neighbors(node):
                if neighbor == end:
                    return path + [neighbor]

                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(path + [neighbor])

        return None

    def find_communities(self, min_size: int = 3) -> List[List[int]]:
        """
        使用简单的连通分量算法发现社区
        返回节点ID列表的列表
        """
        visited = set()
        communities = []

        for node_id in self.nodes:
            if node_id not in visited:
                # BFS找到所有连通的节点
                community = []
                queue = deque([node_id])
                visited.add(node_id)

                while queue:
                    current = queue.popleft()
                    community.append(current)

                    for neighbor, _ in self.get_neighbors(current):
                        if neighbor not in visited:
                            visited.add(neighbor)
                            queue.append(neighbor)

                if len(community) >= min_size:
                    communities.append(community)

        return communities

    def compute_centrality(self) -> Dict[int, float]:
        """
        计算节点的中心性（度中心性）
        返回节点ID到中心性分数的映射
        """
        max_degree = max((self.get_degree(node_id) for node_id in self.nodes), default=1)
        if max_degree == 0:
            max_degree = 1

        centrality = {}
        for node_id in self.nodes:
            degree = self.get_degree(node_id)
            centrality[node_id] = degree / max_degree

        return centrality

    def get_subgraph(self, node_ids: List[int]) -> 'KnowledgeGraph':
        """提取子图，只包含指定的节点和它们之间的边"""
        subgraph = KnowledgeGraph()

        # 添加节点
        node_set = set(node_ids)
        for node_id in node_ids:
            if node_id in self.nodes:
                subgraph.add_node(self.nodes[node_id])

        # 添加边
        for source in node_ids:
            if source in self.edges:
                for target, edge in self.edges[source].items():
                    if target in node_set:
                        subgraph.add_edge(edge)

        return subgraph

    def get_egocentric_network(self, node_id: int, hops: int = 1) -> List[int]:
        """
        获取以某个节点为中心的ego网络
        返回指定跳数内的所有节点ID
        """
        if node_id not in self.nodes:
            return []

        visited = {node_id}
        current_level = {node_id}

        for _ in range(hops):
            next_level = set()
            for node in current_level:
                for neighbor, _ in self.get_neighbors(node):
                    if neighbor not in visited:
                        visited.add(neighbor)
                        next_level.add(neighbor)
            current_level = next_level
            if not current_level:
                break

        return list(visited)

    def to_dict(self) -> dict:
        """导出为字典格式（用于API响应）"""
        return {
            "nodes": [node.to_dict() for node in self.nodes.values()],
            "edges": [edge.to_dict() for source in self.edges for edge in self.edges[source].values()
                      if source < edge.target],  # 避免重复边（无向图）
            "stats": {
                "node_count": len(self.nodes),
                "edge_count": sum(len(edges) for edges in self.edges.values()) // 2,
                "relation_types": list(self.relation_types),
            }
        }


def build_graph_from_memos(memos: List, similarity_threshold: float = 0.5) -> KnowledgeGraph:
    """
    从memos列表构建知识图谱

    参数:
    - memos: Memo对象列表
    - similarity_threshold: 语义相似度阈值，高于此值创建边

    返回:
    - KnowledgeGraph对象
    """
    graph = KnowledgeGraph()

    # 1. 添加所有节点
    for memo in memos:
        # 提取topics
        topics = []
        if memo.structured_summary and isinstance(memo.structured_summary, dict):
            topics = memo.structured_summary.get("topics", [])

        node = GraphNode(
            id=memo.id,
            transcription=memo.transcription or "",
            summary=memo.summary,
            tags=memo.tags or [],
            topics=topics,
            mood_score=memo.mood_score,
            created_at=str(memo.created_at) if memo.created_at else ""
        )
        graph.add_node(node)

    # 2. 创建边
    memo_list = list(memos)
    for i, memo_a in enumerate(memo_list):
        for memo_b in memo_list[i+1:]:
            # 计算关系强度
            edges = []

            # A. 标签重叠
            if memo_a.tags and memo_b.tags:
                tags_a = set(memo_a.tags)
                tags_b = set(memo_b.tags)
                if tags_a & tags_b:
                    jaccard = len(tags_a & tags_b) / len(tags_a | tags_b)
                    edges.append(GraphEdge(
                        source=memo_a.id,
                        target=memo_b.id,
                        weight=jaccard * 0.6,  # 标签权重0.6
                        relation_type="tag",
                        metadata={"shared_tags": list(tags_a & tags_b)}
                    ))

            # B. 情绪相似度
            if memo_a.mood_score is not None and memo_b.mood_score is not None:
                mood_diff = abs(memo_a.mood_score - memo_b.mood_score)
                mood_similarity = max(0, 1 - mood_diff / 2)
                if mood_similarity > 0.3:  # 情绪较相似才创建边
                    edges.append(GraphEdge(
                        source=memo_a.id,
                        target=memo_b.id,
                        weight=mood_similarity * 0.4,  # 情绪权重0.4
                        relation_type="mood",
                        metadata={"mood_similarity": mood_similarity}
                    ))

            # C. 语义相似度（如果有embedding）
            if memo_a.embedding and memo_b.embedding:
                try:
                    vec_a = np.array(memo_a.embedding)
                    vec_b = np.array(memo_b.embedding)
                    norm_a = np.linalg.norm(vec_a)
                    norm_b = np.linalg.norm(vec_b)

                    if norm_a > 0 and norm_b > 0:
                        similarity = float(np.dot(vec_a, vec_b) / (norm_a * norm_b))
                        if similarity > similarity_threshold:
                            edges.append(GraphEdge(
                                source=memo_a.id,
                                target=memo_b.id,
                                weight=similarity,
                                relation_type="semantic",
                                metadata={"similarity": similarity}
                            ))
                except Exception as e:
                    logger.warning(f"计算语义相似度失败 (memo {memo_a.id}, {memo_b.id}): {e}")

            # 添加最强的边（避免多重边）
            if edges:
                # 按权重排序，选择最强的关系
                edges.sort(key=lambda e: e.weight, reverse=True)
                best_edge = edges[0]
                graph.add_edge(best_edge)

    logger.info(f"构建知识图谱: {len(graph.nodes)} 个节点, {sum(len(es) for es in graph.edges.values())//2} 条边")
    return graph


def compute_layout(graph: KnowledgeGraph, width: float = 1000, height: float = 800):
    """
    使用力导向布局算法计算节点位置
    简化版的Fruchterman-Reingold算法
    """
    import random

    # 初始化随机位置
    for node in graph.nodes.values():
        if node.x is None:
            node.x = random.uniform(0, width)
        if node.y is None:
            node.y = random.uniform(0, height)

    # 参数
    k = 100  # 理想边长
    iterations = 50
    cooling = 0.95
    temperature = min(width, height) / 10

    for iteration in range(iterations):
        # 计算排斥力
        forces = {node_id: [0.0, 0.0] for node_id in graph.nodes}

        nodes_list = list(graph.nodes.values())
        for i, node_a in enumerate(nodes_list):
            for node_b in nodes_list[i+1:]:
                dx = node_a.x - node_b.x
                dy = node_a.y - node_b.y
                distance = (dx**2 + dy**2)**0.5

                if distance == 0:
                    distance = 0.1
                    dx = random.uniform(-1, 1)
                    dy = random.uniform(-1, 1)

                # 排斥力
                force = k**2 / distance
                fx = (dx / distance) * force
                fy = (dy / distance) * force

                forces[node_a.id][0] += fx
                forces[node_a.id][1] += fy
                forces[node_b.id][0] -= fx
                forces[node_b.id][1] -= fy

        # 计算吸引力（沿边）
        for source_id, targets in graph.edges.items():
            for target_id, edge in targets.items():
                if source_id < target_id:  # 避免重复处理
                    node_a = graph.nodes[source_id]
                    node_b = graph.nodes[target_id]

                    dx = node_b.x - node_a.x
                    dy = node_b.y - node_a.y
                    distance = (dx**2 + dy**2)**0.5 or 0.1

                    # 吸引力
                    force = distance**2 / k
                    fx = (dx / distance) * force * edge.weight  # 边的权重影响吸引力
                    fy = (dy / distance) * force * edge.weight

                    forces[node_a.id][0] += fx
                    forces[node_a.id][1] += fy
                    forces[node_b.id][0] -= fx
                    forces[node_b.id][1] -= fy

        # 应用力并更新位置
        for node_id, (fx, fy) in forces.items():
            node = graph.nodes[node_id]

            # 限制位移大小
            force_mag = (fx**2 + fy**2)**0.5
            if force_mag > temperature:
                fx = (fx / force_mag) * temperature
                fy = (fy / force_mag) * temperature

            node.x = max(0, min(width, node.x + fx))
            node.y = max(0, min(height, node.y + fy))

        # 冷却
        temperature *= cooling

    logger.info(f"布局计算完成，迭代 {iterations} 次")
