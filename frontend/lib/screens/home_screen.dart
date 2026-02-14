import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../services/api_service.dart';
import 'recorder_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Memo>> _memosFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _refreshMemos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshMemos() {
    setState(() {
      _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
    });
    _animationController.forward(from: 0.0);

    // 检查是否有处理中的笔记，如果有则启动自动刷新
    _startAutoRefreshIfNeeded();
  }

  void _startAutoRefreshIfNeeded() {
    // 取消之前的定时器
    _refreshTimer?.cancel();

    // 加载数据并检查状态
    _memosFuture.then((memos) {
      final hasProcessing = memos.any((memo) => memo.status == 'processing');

      if (hasProcessing && mounted) {
        print('🔄 Found processing memos, starting auto-refresh...');

        // 启动定时器，每3秒刷新一次
        _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) {
            // 刷新数据
            _memosFuture.then((updatedMemos) {
              // 检查是否还有处理中的笔记
              final stillProcessing = updatedMemos.any((m) => m.status == 'processing');

              if (!stillProcessing) {
                // 所有笔记都处理完成了，停止定时器
                print('✅ All memos completed, stopping auto-refresh');
                timer.cancel();
                _refreshTimer = null;
              }
            });

            // 触发刷新
            setState(() {
              _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
            });
          } else {
            timer.cancel();
          }
        });

        print('⏰ Started auto-refresh timer (3s interval)');
      } else {
        print('✅ No processing memos, no auto-refresh needed');
      }
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('⏹️  Stopped auto-refresh timer');
  }

  List<Memo> _filterMemos(List<Memo> memos) {
    if (_searchQuery.isEmpty) return memos;
    final query = _searchQuery.toLowerCase();
    return memos
        .where((memo) =>
            (memo.summary?.toLowerCase().contains(query) ?? false) ||
            (memo.transcription?.toLowerCase().contains(query) ?? false) ||
            memo.tags.any((tag) => tag.toLowerCase().contains(query)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EchoMemo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Voice Journal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // 搜索按钮
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _isSearching = !_isSearching),
              ),
            ],
          ),

          // 搜索栏
          if (_isSearching)
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  trailing: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    ),
                  ],
                  hintText: '搜索笔记...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),

          // 笔记列表
          SliverToBoxAdapter(
            child: FutureBuilder<List<Memo>>(
              future: _memosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            '加载失败',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshMemos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_off,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '还没有笔记',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击下方按钮开始录制',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final memos = _filterMemos(snapshot.data!);
                if (memos.isEmpty && _searchQuery.isNotEmpty) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64),
                          SizedBox(height: 16),
                          Text('没有找到匹配的笔记'),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: memos.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final memo = memos[index];
                      return _MemoCard(memo: memo);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 停止之前的自动刷新
          _stopAutoRefresh();

          // 打开录制界面
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const RecorderScreen(),
            ),
          );

          // 录制完成后刷新数据（这将启动自动刷新）
          _refreshMemos();
        },
        icon: const Icon(Icons.mic),
        label: const Text('录制'),
        elevation: 8,
      ),
    );
  }

  Color _getMoodColor(double? score) {
    if (score == null) return Colors.grey;
    if (score > 0.5) return Colors.green;
    if (score < -0.5) return Colors.red;
    return Colors.amber;
  }
}

// 现代化的笔记卡片
class _MemoCard extends StatelessWidget {
  final Memo memo;

  const _MemoCard({required this.memo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodColor = _getMoodColor(memo.moodScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: 显示详情
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('查看详情: ${memo.summary ?? "Processing..."}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：情感和时间
              Row(
                children: [
                  // 情感标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: moodColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMoodIcon(memo.moodScore),
                          size: 16,
                          color: moodColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          memo.moodLabel ?? '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: moodColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 时间
                  Text(
                    DateFormat('MM/dd HH:mm').format(memo.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 转写内容（完整文本）
              if (memo.transcription != null && memo.transcription!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.transcribe,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '转写文本',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memo.transcription!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // AI摘要（如果有）
              if (memo.summary != null && memo.summary!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI摘要',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memo.summary!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // 处理中状态
              if (memo.status == 'processing' && (memo.transcription == null || memo.transcription!.isEmpty))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI处理中...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // 标签
              if (memo.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: memo.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(double? score) {
    if (score == null) return Colors.grey;
    if (score > 0.5) return Colors.green;
    if (score < -0.5) return Colors.red;
    return Colors.amber;
  }

  IconData _getMoodIcon(double? score) {
    if (score == null) return Icons.help_outline;
    if (score > 0.5) return Icons.sentiment_very_satisfied;
    if (score > 0) return Icons.sentiment_satisfied;
    if (score < -0.5) return Icons.sentiment_very_dissatisfied;
    if (score < 0) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_neutral;
  }
}
