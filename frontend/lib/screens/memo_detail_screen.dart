import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/memo.dart';
import '../services/api_service.dart';

class MemoDetailScreen extends StatefulWidget {
  final Memo memo;

  const MemoDetailScreen({Key? key, required this.memo}) : super(key: key);

  @override
  State<MemoDetailScreen> createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECFEFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E63)),
          onPressed: () => Navigator.pop(context, true), // 返回true表示可能已删除
        ),
        title: const Text(
          '笔记详情',
          style: TextStyle(
            color: Color(0xFF164E63),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0891B2)),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF164E63)),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateTime(),
            const SizedBox(height: 20),
            _buildTranscription(),
            const SizedBox(height: 20),
            if (widget.memo.status == 'completed' && widget.memo.summary != null) ...[
              _buildSummary(),
              const SizedBox(height: 20),
            ],
            if (widget.memo.status == 'completed' && widget.memo.tags.isNotEmpty) ...[
              _buildTags(),
              const SizedBox(height: 20),
            ],
            if (widget.memo.status == 'completed' && widget.memo.moodLabel != null) ...[
              _buildMood(),
              const SizedBox(height: 20),
            ],
            _buildAudioPlayer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTime() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0891B2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.access_time,
            color: Color(0xFF0891B2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          DateFormat('yyyy年MM月dd日 HH:mm').format(widget.memo.createdAt),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF164E63),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscription() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.transcribe,
                  color: Color(0xFF0891B2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '转录文本',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0891B2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.memo.transcription != null && widget.memo.transcription!.isNotEmpty)
            Text(
              widget.memo.transcription!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF164E63),
              ),
            )
          else if (widget.memo.status == 'processing')
            const Text(
              'AI正在处理中...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0891B2),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            const Text(
              '暂无转录文本',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF164E63),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI摘要',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.memo.summary ?? '',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF164E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '标签',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.memo.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF22D3EE).withOpacity(0.3),
                      const Color(0xFF0891B2).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0891B2).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF164E63),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMood() {
    final moodScore = widget.memo.moodScore ?? 0;
    final moodIcon = _getMoodIcon(moodScore);
    final moodColor = _getMoodColor(moodScore);

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  moodIcon,
                  color: moodColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '情绪',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(moodIcon, color: moodColor, size: 32),
              const SizedBox(width: 12),
              Text(
                widget.memo.moodLabel ?? '未分析',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: moodColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  moodScore > 0 ? '+${moodScore.toStringAsFixed(1)}' : moodScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: moodColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '录音',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEC4899),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEC4899).withOpacity(0.1),
                  const Color(0xFF0891B2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFF0891B2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '点击播放录音',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF164E63),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '音频文件将在未来版本中支持播放',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF164E63).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
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

  IconData _getMoodIcon(double score) {
    if (score > 0.5) return Icons.sentiment_very_satisfied;
    if (score > 0) return Icons.sentiment_satisfied;
    if (score < -0.5) return Icons.sentiment_very_dissatisfied;
    if (score < 0) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_neutral;
  }

  Color _getMoodColor(double score) {
    if (score > 0.5) return const Color(0xFF059669); // 绿色 - 非常积极
    if (score > 0) return const Color(0xFF22D3EE); // 青色 - 积极
    if (score < -0.5) return const Color(0xFFDC2626); // 红色 - 非常消极
    if (score < 0) return const Color(0xFFF59E0B); // 橙色 - 消极
    return const Color(0xFF6B7280); // 灰色 - 中性
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '删除笔记',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF164E63),
          ),
        ),
        content: const Text(
          '确定要删除这条笔记吗？删除后将无法恢复。',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF164E63),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF164E63),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // 关闭对话框
              await _deleteMemo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '删除',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMemo() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await ApiService().deleteMemo(widget.memo.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('笔记已删除'),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 2),
          ),
        );

        // 返回到上一页，并传递true表示已删除
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
