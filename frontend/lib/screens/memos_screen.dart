import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class MemosScreen extends StatefulWidget {
  const MemosScreen({super.key});

  @override
  State<MemosScreen> createState() => _MemosScreenState();
}

class _MemosScreenState extends State<MemosScreen> {
  late Future<List<Memo>> _memosFuture;
  String _filter = '今天';

  @override
  void initState() {
    super.initState();
    _refreshMemos();
  }

  void _refreshMemos() {
    setState(() {
      _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '思维胶囊',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF164E63),
                  ),
                ),
                Row(
                  children: [
                    _buildFilterChip('今天', _filter == '今天'),
                    const SizedBox(width: 8),
                    _buildFilterChip('本周', _filter == '本周'),
                    const SizedBox(width: 8),
                    _buildFilterChip('本月', _filter == '本月'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Memo>>(
              future: _memosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(snapshot.error.toString()),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshMemos,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_off,
                          size: 80,
                          color: const Color(0xFF0891B2).withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '还没有笔记',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF164E63),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击下方按钮开始录制',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF164E63).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final memos = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMemoItem(memos[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0891B2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0891B2) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF164E63),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMemoItem(Memo memo) {
    final tag = memo.tags.isNotEmpty ? memo.tags.first : '未分类';
    final tagColor = _getTagColor(tag);
    final tagIcon = _getTagIcon(tag);

    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tagIcon, color: tagColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 6),
                if (memo.summary != null && memo.summary!.isNotEmpty)
                  Text(
                    memo.summary!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF164E63),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (memo.transcription != null && memo.transcription!.isNotEmpty)
                  Text(
                    memo.transcription!,
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
                Row(
                  children: [
                    if (memo.moodLabel != null) ...[
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
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: const Color(0xFF164E63).withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeAgo(memo.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF164E63).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  IconData _getTagIcon(String tag) {
    final icons = {
      '工作': Icons.work_outline,
      '情绪': Icons.favorite_outline,
      '灵感': Icons.lightbulb_outline,
      '生活': Icons.home_outlined,
    };
    return icons[tag] ?? Icons.label_outline;
  }

  IconData _getMoodIcon(double? score) {
    if (score == null) return Icons.help_outline;
    if (score > 0.5) return Icons.sentiment_very_satisfied;
    if (score > 0) return Icons.sentiment_satisfied;
    if (score < -0.5) return Icons.sentiment_very_dissatisfied;
    if (score < 0) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_neutral;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
