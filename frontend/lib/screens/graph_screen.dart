import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/graph_node.dart';
import '../services/api_service.dart';
import '../widgets/graph_painter.dart';
import 'memo_detail_screen.dart';

/// 知识图谱可视化屏幕
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> with TickerProviderStateMixin {
  // 图数据
  KnowledgeGraphData? _graphData;
  bool _isLoading = true;
  String? _error;

  // 视图变换
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset? _lastPanPosition;
  double? _lastScaleStart;

  // 交互状态
  int? _selectedNodeId;
  int? _hoveredNodeId;
  Offset? _dragStartPosition;
  double? _nodeRadius;

  // 控制器
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();

    _loadGraph();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadGraph() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // 获取图数据
      final jsonData = await apiService.getKnowledgeGraph(
        similarityThreshold: 0.5,
        computeLayout: true,
      );

      setState(() {
        _graphData = KnowledgeGraphData.fromJson(jsonData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载出错: $e';
        _isLoading = false;
      });
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScaleStart = _scale;
    setState(() {
      _dragStartPosition = details.localFocalPoint;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // 缩放
    if (_lastScaleStart != null) {
      final newScale = _lastScaleStart! * details.scale;
      setState(() {
        _scale = newScale.clamp(0.3, 3.0); // 限制缩放范围
      });
    }

    // 平移
    if (_dragStartPosition != null) {
      final delta = details.localFocalPoint - _dragStartPosition!;
      setState(() {
        _offset += delta;
        _dragStartPosition = details.localFocalPoint;
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _lastScaleStart = null;
      _dragStartPosition = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  Offset? _screenToCanvas(Offset screenPosition, Size canvasSize) {
    // 将屏幕坐标转换为画布坐标
    final x = (screenPosition.dx - _offset.dx) / _scale;
    final y = (screenPosition.dy - _offset.dy) / _scale;
    return Offset(x, y);
  }

  int? _getNodeAtPosition(Offset position) {
    if (_graphData == null) return null;

    final canvasPos = _screenToCanvas(position, Size.infinite);
    if (canvasPos == null) return null;

    for (final node in _graphData!.nodes) {
      final nodePos = Offset(node.x, node.y);
      final distance = (canvasPos - nodePos).distance;
      final radius = node.radius ?? 20.0;

      if (distance <= radius) {
        return node.id;
      }
    }

    return null;
  }

  void _handleTap(TapUpDetails details) {
    final nodeId = _getNodeAtPosition(details.localPosition);

    setState(() {
      if (nodeId != null) {
        _selectedNodeId = nodeId == _selectedNodeId ? null : nodeId;
      } else {
        _selectedNodeId = null;
      }
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    final nodeId = _getNodeAtPosition(details.localPosition);

    if (nodeId != null) {
      setState(() {
        _selectedNodeId = nodeId;
      });
    }
  }

  void _navigateToMemo() async {
    if (_selectedNodeId != null) {
      try {
        // Fetch the memo first
        final apiService = Provider.of<ApiService>(context, listen: false);
        final memo = await apiService.getMemo(_selectedNodeId!);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoDetailScreen(memo: memo),
            ),
          ).then((_) => _loadGraph()); // 返回时刷新
        }
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('加载笔记失败: $e')),
          );
        }
      }
    }
  }

  void _resetView() {
    setState(() {
      _offset = Offset.zero;
      _scale = 1.0;
      _selectedNodeId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('知识图谱'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGraph,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _resetView,
            tooltip: '重置视图',
          ),
          IconButton(
            icon: Icon(_selectedNodeId != null ? Icons.info_outline : Icons.info),
            onPressed: _selectedNodeId != null
                ? () => setState(() => _selectedNodeId = null)
                : null,
            tooltip: '信息',
          ),
        ],
      ),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGraphInfo(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在构建知识图谱...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadGraph,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_graphData == null || _graphData!.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '暂无图谱数据',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '请先创建一些笔记',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // 图谱画布
          GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            onPanUpdate: _handlePanUpdate,
            onTapUp: (details) => _handleTap(details),
            onLongPressStart: _handleLongPressStart,
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              size: Size.infinite,
              painter: GraphPainter(
                nodes: _graphData!.nodes,
                edges: _graphData!.edges,
                offset: _offset,
                scale: _scale,
                selectedNodeId: _selectedNodeId,
                hoveredNodeId: _hoveredNodeId,
              ),
            ),
          ),

          // 缩放指示器
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildZoomControls(theme),
          ),

          // 统计信息
          Positioned(
            left: 16,
            top: 16,
            child: _buildStatsCard(theme),
          ),

          // 节点详情卡片
          if (_selectedNodeId != null)
            NodeInfoCard(
              node: _graphData!.nodes.firstWhere((n) => n.id == _selectedNodeId),
              onClose: () => setState(() => _selectedNodeId = null),
              onNavigate: _navigateToMemo,
            ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(ThemeData theme) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: _scale > 0.4
                  ? () => setState(() => _scale = (_scale - 0.2).clamp(0.3, 3.0))
                  : null,
              tooltip: '缩小',
            ),
            Text(
              '${(_scale * 100).toInt()}%',
              style: theme.textTheme.labelLarge,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: _scale < 2.9
                  ? () => setState(() => _scale = (_scale + 0.2).clamp(0.3, 3.0))
                  : null,
              tooltip: '放大',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface.withOpacity(0.9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_tree,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '知识图谱',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatItem('节点', _graphData!.nodeCount.toString()),
                const SizedBox(width: 16),
                _buildStatItem('边', _graphData!.edgeCount.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showGraphInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('知识图谱'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '操作指南',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoItem('🔍 缩放', '双指捏合或使用左下角按钮'),
              _buildInfoItem('✋ 平移', '单指拖动画布'),
              _buildInfoItem('👆 选择', '点击节点查看详情'),
              _buildInfoItem('📊 节点大小', '表示重要程度'),
              const SizedBox(height: 12),
              const Text(
                '边的含义',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildEdgeInfo('🟣 紫色', '语义相似'),
              _buildEdgeInfo('🟠 橙色', '共享标签'),
              _buildEdgeInfo('🔵 蓝色', '情绪相似'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(title)),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildEdgeInfo(String color, String meaning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(color),
          const SizedBox(width: 8),
          Text(meaning),
        ],
      ),
    );
  }
}
