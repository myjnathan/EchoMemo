import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '思维洞察',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164E63),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInsightCard('情绪趋势', Icons.mood, const Color(0xFF0891B2), '本周整体偏积极')),
                const SizedBox(width: 12),
                Expanded(child: _buildInsightCard('主题关联', Icons.link, const Color(0xFF8B5CF6), '发现 3 个相关')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInsightCard('今日回响', Icons.history, const Color(0xFF059669), '去年的今天')),
                const SizedBox(width: 12),
                Expanded(child: _buildInsightCard('本周洞见', Icons.auto_awesome, const Color(0xFFEC4899), 'AI 为您总结')),
              ],
            ),
            const SizedBox(height: 24),
            _buildEmotionChart(),
            const SizedBox(height: 24),
            _buildTopicConnections(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, IconData icon, Color color, String subtitle) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF164E63),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF164E63).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChart() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '情绪趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF164E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '本周整体情绪偏积极，周三略有波动',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF164E63).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(0.6, '周一'),
              _buildBar(0.8, '周二'),
              _buildBar(0.5, '周三'),
              _buildBar(0.7, '周四'),
              _buildBar(0.9, '周五'),
              _buildBar(0.75, '周六'),
              _buildBar(0.85, '周日'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String day) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 64 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: height > 0.7
                  ? [const Color(0xFF059669), const Color(0xFF22D3EE)]
                  : [const Color(0xFF0891B2), const Color(0xFF67E8F9)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF164E63).withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicConnections() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '主题关联',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF164E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '发现 3 个相关主题',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF164E63).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          _buildConnection('工作', '职业发展', const Color(0xFF0891B2), const Color(0xFF059669)),
          const SizedBox(height: 12),
          _buildConnection('自我成长', '人生规划', const Color(0xFFEC4899), const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildConnection(String from, String to, Color fromColor, Color toColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: fromColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            from,
            style: TextStyle(
              fontSize: 12,
              color: fromColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF164E63)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: toColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            to,
            style: TextStyle(
              fontSize: 12,
              color: toColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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
