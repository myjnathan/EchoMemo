import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/memo.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<List<Memo>> _memosFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _memosFuture = Provider.of<ApiService>(context, listen: false).getMemos();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _refreshData();
          });
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFF0891B2),
        backgroundColor: const Color(0xFFECFEFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '思维洞察',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF164E63),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF0891B2)),
                    onPressed: () {
                      setState(() {
                        _refreshData();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildMoodDistribution(),
              const SizedBox(height: 24),
              _buildTagDistribution(),
              const SizedBox(height: 24),
              _buildWeeklyActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return FutureBuilder<List<Memo>>(
      future: _memosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final memos = snapshot.data!;
        final totalMemos = memos.length;
        final insightsCount = memos.where((m) => m.summary != null && m.summary!.isNotEmpty).length;
        final avgMood = _calculateAverageMood(memos);

        return Row(
          children: [
            Expanded(child: _buildStatCard('总笔记', '$totalMemos', Icons.article, const Color(0xFF0891B2))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('洞察发现', '$insightsCount', Icons.lightbulb, const Color(0xFFF59E0B))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('平均情绪', avgMood, Icons.mood, _getMoodColor(avgMood))),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF164E63).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAverageMood(List<Memo> memos) {
    final moodMemos = memos.where((m) => m.moodScore != null).toList();
    if (moodMemos.isEmpty) return 'N/A';

    final total = moodMemos.fold<double>(0, (sum, m) => sum + (m.moodScore ?? 0));
    final avg = total / moodMemos.length;

    if (avg > 0.5) return '积极';
    if (avg > 0) return '偏积极';
    if (avg < -0.5) return '消极';
    if (avg < 0) return '偏消极';
    return '中性';
  }

  Color _getMoodColor(String moodLabel) {
    switch (moodLabel) {
      case '积极':
        return const Color(0xFF059669);
      case '偏积极':
        return const Color(0xFF10B981);
      case '中性':
        return const Color(0xFF0891B2);
      case '偏消极':
        return const Color(0xFFF59E0B);
      case '消极':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildMoodDistribution() {
    return FutureBuilder<List<Memo>>(
      future: _memosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final moodCounts = <String, int>{};
        for (final memo in snapshot.data!) {
          if (memo.moodLabel != null) {
            moodCounts[memo.moodLabel!] = (moodCounts[memo.moodLabel!] ?? 0) + 1;
          }
        }

        if (moodCounts.isEmpty) {
          return const SizedBox.shrink();
        }

        final total = moodCounts.values.reduce((a, b) => a + b);

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '情绪分布',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF164E63),
                ),
              ),
              const SizedBox(height: 16),
              ...moodCounts.entries.map((entry) {
                final percentage = (entry.value / total * 100).toInt();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF164E63),
                            ),
                          ),
                          Text(
                            '$entry.value (${percentage}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF164E63).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFEFF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: entry.value / total,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getMoodBarColor(entry.key),
                                    _getMoodBarColor(entry.key).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getMoodBarColor(String moodLabel) {
    switch (moodLabel) {
      case '积极':
      case 'Happy':
        return const Color(0xFF059669);
      case '偏积极':
        return const Color(0xFF10B981);
      case '中性':
      case 'Neutral':
        return const Color(0xFF0891B2);
      case '偏消极':
        return const Color(0xFFF59E0B);
      case '消极':
      case 'Anxious':
      case 'Sad':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildTagDistribution() {
    return FutureBuilder<List<Memo>>(
      future: _memosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final tagCounts = <String, int>{};
        for (final memo in snapshot.data!) {
          for (final tag in memo.tags) {
            tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
          }
        }

        if (tagCounts.isEmpty) {
          return const SizedBox.shrink();
        }

        final sortedTags = tagCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topTags = sortedTags.take(5).toList();

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '热门标签',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF164E63),
                ),
              ),
              const SizedBox(height: 16),
              ...topTags.asMap().entries.map((entry) {
                final index = entry.key;
                final tagEntry = entry.value;
                final tag = tagEntry.key;
                final count = tagEntry.value;
                final maxCount = topTags.first.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0891B2).withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: count / maxCount,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _getTagColor(tag).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getTagColor(tag),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF164E63).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getTagColor(String tag) {
    final colors = {
      '工作': const Color(0xFF0891B2),
      '情绪': const Color(0xFF059669),
      '灵感': const Color(0xFF8B5CF6),
      '生活': const Color(0xFFEC4899),
      '学习': const Color(0xFF3B82F6),
      '会议': const Color(0xFFF59E0B),
      '想法': const Color(0xFFEF4444),
      '项目': const Color(0xFF10B981),
      '健康': const Color(0xFF6366F1),
    };

    if (colors.containsKey(tag)) {
      return colors[tag]!;
    }

    final hashCode = tag.hashCode;
    final colorOptions = [
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
    ];

    final index = hashCode.abs() % colorOptions.length;
    return colorOptions[index];
  }

  Widget _buildWeeklyActivity() {
    return FutureBuilder<List<Memo>>(
      future: _memosFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final weeklyData = List.generate(7, (index) {
          final day = now.subtract(Duration(days: 6 - index));
          final dayMemos = snapshot.data!.where((memo) {
            return memo.createdAt.year == day.year &&
                   memo.createdAt.month == day.month &&
                   memo.createdAt.day == day.day;
          }).length;

          return MapEntry(day, dayMemos);
        });

        final maxCount = weeklyData.map((e) => e.value).fold<int>(0, (max, count) => count > max ? count : max);

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '本周活动',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF164E63),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyData.map((entry) {
                  final day = entry.key;
                  final count = entry.value;
                  final height = maxCount > 0 ? count / maxCount : 0.0;
                  final dayLabel = _getDayLabel(day.weekday);

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 80 * height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: count > 0
                                  ? [const Color(0xFF0891B2), const Color(0xFF22D3EE)]
                                  : [const Color(0xFFECFEFF), const Color(0xFFECFEFF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: count > 0
                                ? const Color(0xFF164E63)
                                : const Color(0xFF164E63).withOpacity(0.4),
                            fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (count > 0)
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF164E63).withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1: return '周一';
      case 2: return '周二';
      case 3: return '周三';
      case 4: return '周四';
      case 5: return '周五';
      case 6: return '周六';
      case 7: return '周日';
      default: return '';
    }
  }

  Widget _buildEmptyState() {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 48,
            color: const Color(0xFF0891B2).withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            '暂无洞察数据',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF164E63),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
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
