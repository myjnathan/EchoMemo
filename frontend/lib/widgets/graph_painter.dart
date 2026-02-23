import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import '../models/graph_node.dart';

/// 知识图谱绘制器
class GraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Offset offset; // 平移偏移
  final double scale; // 缩放比例
  final int? selectedNodeId; // 选中的节点
  final int? hoveredNodeId; // 悬停的节点

  GraphPainter({
    required this.nodes,
    required this.edges,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.selectedNodeId,
    this.hoveredNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    _drawBackground(canvas, size);

    // 应用变换
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale, scale);

    // 绘制边
    _drawEdges(canvas);

    // 绘制节点
    _drawNodes(canvas);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 绘制网格（可选）
    _drawGrid(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.5;

    const gridSize = 50.0;
    final scaledGridSize = gridSize * scale;

    // 垂直线
    for (double x = offset.dx % scaledGridSize; x < size.width; x += scaledGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 水平线
    for (double y = offset.dy % scaledGridSize; y < size.height; y += scaledGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawEdges(Canvas canvas) {
    for (final edge in edges) {
      final sourceNode = nodes.firstWhere((n) => n.id == edge.source);
      final targetNode = nodes.firstWhere((n) => n.id == edge.target);

      final start = Offset(sourceNode.x, sourceNode.y);
      final end = Offset(targetNode.x, targetNode.y);

      // 绘制边
      final edgePaint = Paint()
        ..color = Color(edge.color).withOpacity(edge.opacity)
        ..strokeWidth = edge.width / scale // 保持视觉宽度一致
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, edgePaint);

      // 绘制关系类型标识（小圆点在边的中点）
      final midPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      final dotPaint = Paint()
        ..color = Color(edge.color).withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(midPoint, 3 / scale, dotPaint);
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final node in nodes) {
      final position = Offset(node.x, node.y);
      final radius = node.radius ?? 20.0;
      final isSelected = node.id == selectedNodeId;
      final isHovered = node.id == hoveredNodeId;

      // 绘制阴影
      if (isSelected || isHovered) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(position, radius + 4, shadowPaint);
      }

      // 绘制外圈（选中效果）
      if (isSelected) {
        final outerPaint = Paint()
          ..color = const Color(0xFF9C27B0).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(position, radius + 6, outerPaint);
      }

      // 绘制节点背景
      final nodePaint = Paint()
        ..color = Color(node.getColor())
        ..style = PaintingStyle.fill;

      // 使用渐变
      final gradient = RadialGradient(
        colors: [
          Color(node.getColor()),
          Color(node.getColor()).withOpacity(0.7),
        ],
      );
      final rect = Rect.fromCircle(center: position, radius: radius);
      nodePaint.shader = gradient.createShader(rect);

      canvas.drawCircle(position, radius, nodePaint);

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2 / scale
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(position, radius, borderPaint);

      // 绘制ID或首字母
      _drawNodeLabel(canvas, position, radius, node);
    }
  }

  void _drawNodeLabel(Canvas canvas, Offset position, double radius, GraphNode node) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.id.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 / scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.scale != scale ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.hoveredNodeId != hoveredNodeId;
  }
}

/// 节点信息卡片
class NodeInfoCard extends StatelessWidget {
  final GraphNode node;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const NodeInfoCard({
    super.key,
    required this.node,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300, minWidth: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(node.getColor()).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(node.getColor()),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '笔记 #${node.id}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 16),

              // 内容预览
              if (node.summary != null && node.summary!.isNotEmpty) ...[
                Text(
                  '摘要',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  node.summary!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // 标签
              if (node.tags.isNotEmpty) ...[
                Text(
                  '标签',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: node.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // 主题
              if (node.topics.isNotEmpty) ...[
                Text(
                  '主题',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: node.topics.take(3).map((topic) {
                    return Chip(
                      label: Text(topic),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: Color(node.getColor()).withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // 情绪
              if (node.moodScore != null) ...[
                Text(
                  '情绪',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      node.moodScore! > 0 ? Icons.sentiment_satisfied : Icons.sentiment_neutral,
                      size: 16,
                      color: node.moodScore! > 0 ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      node.moodScore!.toStringAsFixed(2),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // 查看详情按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('查看详情'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(node.getColor()),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
