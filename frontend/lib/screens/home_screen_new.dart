import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../services/api_service.dart';
import 'recorder_screen_new.dart';
import 'memo_detail_screen.dart';
import '../widgets/search_highlighted_text.dart';
import 'package:intl/intl.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  late Future<List<Memo>> _memosFuture;
  Timer? _refreshTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshMemos();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshMemos() {
    setState(() {
      _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
    });
    _startAutoRefreshIfNeeded();
  }

  void _startAutoRefreshIfNeeded() {
    _refreshTimer?.cancel();

    _memosFuture.then((memos) {
      final hasProcessing = memos.any((memo) => memo.status == 'processing');

      if (hasProcessing && mounted) {
        _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) {
            _memosFuture.then((updatedMemos) {
              final stillProcessing = updatedMemos.any((m) => m.status == 'processing');
              if (!stillProcessing) {
                timer.cancel();
                _refreshTimer = null;
              }
            });
            setState(() {
              _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
            });
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  List<Memo> _filterMemos(List<Memo> memos) {
    if (_searchQuery.isEmpty) return memos;

    final query = _searchQuery.toLowerCase();
    return memos.where((memo) {
      // 搜索转录文本
      if (memo.transcription?.toLowerCase().contains(query) == true) {
        return true;
      }

      // 搜索摘要
      if (memo.summary?.toLowerCase().contains(query) == true) {
        return true;
      }

      // 搜索标签
      if (memo.tags.any((tag) => tag.toLowerCase().contains(query))) {
        return true;
      }

      return false;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    // 取消现有的定时器
    _refreshTimer?.cancel();
    _refreshTimer = null;

    // 刷新数据
    _refreshMemos();

    // 等待一小段时间确保刷新完成
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void didUpdateWidget(HomeScreenNew oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当widget更新时（比如从详情页返回），检查是否需要刷新
    _refreshMemos();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF0891B2),
        backgroundColor: const Color(0xFFECFEFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBox(),
              const SizedBox(height: 24),
              _buildQuickRecord(context),
              const SizedBox(height: 24),
              _buildStats(),
              const SizedBox(height: 24),
              _buildRecentMemos(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '记录即存在',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164E63),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '用声音捕捉思维的瞬息',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF164E63).withOpacity(0.6),
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0891B2).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索笔记...',
          hintStyle: TextStyle(
            color: const Color(0xFF164E63).withOpacity(0.5),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF0891B2),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF0891B2),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildQuickRecord(BuildContext context) {
    return GlassCard(
      onTap: () => _showRecordingSheet(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '点击开始录音',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF164E63),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '随时随地捕捉灵感',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF164E63),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF164E63)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return FutureBuilder<List<Memo>>(
      future: _memosFuture,
      builder: (context, snapshot) {
        int memoCount = 0;
        if (snapshot.hasData) {
          memoCount = snapshot.data!.length;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('$memoCount', '思维胶囊'),
            _buildStatItem('${memoCount * 2}m', '记录时长'),
            _buildStatItem('${memoCount > 0 ? memoCount + 5 : 0}', '洞察发现'),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0891B2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF164E63).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMemos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _searchQuery.isEmpty ? '最近记录' : '搜索结果',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF164E63),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                '查看全部',
                style: TextStyle(color: Color(0xFF0891B2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Memo>>(
          future: _memosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildEmptyState();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            // 应用搜索过滤
            final memos = _filterMemos(snapshot.data!);
            final displayMemos = _searchQuery.isEmpty ? memos.take(2).toList() : memos;

            if (displayMemos.isEmpty) {
              return Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: const Color(0xFF0891B2).withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '未找到匹配的笔记',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF164E63).withOpacity(0.6),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: displayMemos.map((memo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMemoCard(memo),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMemoCard(Memo memo) {
    final tag = memo.tags.isNotEmpty ? memo.tags.first : '未分类';
    final tagColor = _getTagColor(tag);

    return GlassCard(
      onTap: () async {
        // 导航到详情页，等待返回结果
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoDetailScreen(memo: memo),
          ),
        );

        // 如果返回true，表示删除了memo，需要刷新列表
        if (result == true && mounted) {
          _refreshMemos();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MM/dd HH:mm').format(memo.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF164E63).withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    color: tagColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (memo.summary != null && memo.summary!.isNotEmpty)
            SearchHighlightedText(
              text: memo.summary!,
              query: _searchQuery,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF164E63),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else if (memo.transcription != null && memo.transcription!.isNotEmpty)
            SearchHighlightedText(
              text: memo.transcription!,
              query: _searchQuery,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF164E63),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              memo.status == 'processing' ? 'AI处理中...' : '暂无内容',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF164E63).withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          if (memo.moodLabel != null)
            Row(
              children: [
                Icon(
                  _getMoodIcon(memo.moodScore),
                  size: 12,
                  color: const Color(0xFF164E63).withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  memo.moodLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF164E63).withOpacity(0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        GlassCard(
          child: Column(
            children: [
              Icon(
                Icons.mic_off,
                size: 48,
                color: const Color(0xFF0891B2).withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                '还没有记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF164E63),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    final colors = {
      '工作': const Color(0xFF0891B2),
      '情绪': const Color(0xFF059669),
      '灵感': const Color(0xFF8B5CF6),
      '生活': const Color(0xFFEC4899),
    };
    return colors[tag] ?? const Color(0xFF0891B2);
  }

  IconData _getMoodIcon(double? score) {
    if (score == null) return Icons.help_outline;
    if (score > 0.5) return Icons.sentiment_very_satisfied;
    if (score > 0) return Icons.sentiment_satisfied;
    if (score < -0.5) return Icons.sentiment_very_dissatisfied;
    if (score < 0) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_neutral;
  }

  void _showRecordingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecorderScreenNew(),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0891B2).withOpacity(0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
