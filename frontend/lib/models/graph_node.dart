/// 图节点数据模型
class GraphNode {
  final int id;
  final String transcription;
  final String? summary;
  final List<String> tags;
  final List<String> topics;
  final double? moodScore;
  final String createdAt;
  double x; // 画布坐标（可变）
  double y; // 画布坐标（可变）
  double? radius; // 节点半径（根据重要性计算）

  GraphNode({
    required this.id,
    required this.transcription,
    this.summary,
    required this.tags,
    required this.topics,
    this.moodScore,
    required this.createdAt,
    required this.x,
    required this.y,
    this.radius,
  });

  /// 从JSON创建
  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id'] as int,
      transcription: json['transcription'] as String? ?? '',
      summary: json['summary'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      topics: (json['topics'] as List<dynamic>?)
               ?.map((e) => e.toString())
               .toList() ??
          [],
      moodScore: (json['mood_score'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 获取显示文本
  String get displayText {
    if (summary != null && summary!.isNotEmpty) {
      return summary!;
    }
    return transcription.length > 30
        ? '${transcription.substring(0, 30)}...'
        : transcription;
  }

  /// 获取主要主题
  String get primaryTopic {
    return topics.isNotEmpty ? topics[0] : (tags.isNotEmpty ? tags[0] : '');
  }

  /// 计算颜色（基于情绪或主题）
  int getColor() {
    if (moodScore != null) {
      // 基于情绪生成颜色
      if (moodScore! > 0.3) return 0xFF4CAF50; // 绿色 - 积极
      if (moodScore! < -0.3) return 0xFFF44336; // 红色 - 消极
      return 0xFF2196F3; // 蓝色 - 中性
    }
    // 基于主题生成颜色
    final topicColors = [
      0xFF9C27B0, // 紫色
      0xFFFF9800, // 橙色
      0xFF00BCD4, // 青色
      0xFFE91E63, // 粉色
      0xFFFFC107, // 琥珀
    ];
    if (topics.isNotEmpty) {
      final index = topics[0].hashCode % topicColors.length;
      return topicColors[index];
    }
    return 0xFF9C27B0; // 默认紫色
  }
}

/// 图边数据模型
class GraphEdge {
  final int source;
  final int target;
  final double weight;
  final String relationType; // semantic, tag, mood
  final Map<String, dynamic> metadata;

  GraphEdge({
    required this.source,
    required this.target,
    required this.weight,
    required this.relationType,
    required this.metadata,
  });

  /// 从JSON创建
  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      source: json['source'] as int,
      target: json['target'] as int,
      weight: (json['weight'] as num).toDouble(),
      relationType: json['relation_type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 获取边宽（基于权重）
  double get width => 1.0 + weight * 3.0;

  /// 获取边颜色（基于关系类型）
  int get color {
    switch (relationType) {
      case 'semantic':
        return 0xFF9C27B0; // 紫色 - 语义
      case 'tag':
        return 0xFFFF9800; // 橙色 - 标签
      case 'mood':
        return 0xFF2196F3; // 蓝色 - 情绪
      default:
        return 0xFF9E9E9E; // 灰色 - 其他
    }
  }

  /// 获取边的透明度
  double get opacity => 0.3 + weight * 0.5;
}

/// 知识图谱数据
class KnowledgeGraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final int nodeCount;
  final int edgeCount;

  KnowledgeGraphData({
    required this.nodes,
    required this.edges,
    required this.nodeCount,
    required this.edgeCount,
  });

  /// 从JSON创建
  factory KnowledgeGraphData.fromJson(Map<String, dynamic> json) {
    final nodesList = (json['nodes'] as List<dynamic>?)
            ?.map((e) => GraphNode.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final edgesList = (json['edges'] as List<dynamic>?)
            ?.map((e) => GraphEdge.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return KnowledgeGraphData(
      nodes: nodesList,
      edges: edgesList,
      nodeCount: stats['node_count'] as int? ?? nodesList.length,
      edgeCount: stats['edge_count'] as int? ?? edgesList.length,
    );
  }

  /// 获取节点的所有连接边
  List<GraphEdge> getEdgesForNode(int nodeId) {
    return edges.where((e) => e.source == nodeId || e.target == nodeId).toList();
  }

  /// 计算节点的度数
  int getNodeDegree(int nodeId) {
    return getEdgesForNode(nodeId).length;
  }
}
