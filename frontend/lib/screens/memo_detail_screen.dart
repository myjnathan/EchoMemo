import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memo.dart';
import '../services/api_service.dart';
import '../services/error_handler.dart';

class MemoDetailScreen extends StatefulWidget {
  final Memo memo;

  const MemoDetailScreen({Key? key, required this.memo}) : super(key: key);

  @override
  State<MemoDetailScreen> createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  bool _isDeleting = false;
  bool _isEditing = false;
  bool _isSaving = false;

  // 编辑控制器
  late TextEditingController _transcriptionController;
  late TextEditingController _summaryController;
  late List<String> _editedTags;

  // Focus nodes
  late FocusNode _transcriptionFocusNode;
  late FocusNode _summaryFocusNode;

  @override
  void initState() {
    super.initState();
    // 初始化编辑控制器
    _transcriptionController = TextEditingController(text: widget.memo.transcription ?? '');
    _summaryController = TextEditingController(text: widget.memo.summary ?? '');
    _editedTags = List<String>.from(widget.memo.tags);

    // 初始化focus nodes
    _transcriptionFocusNode = FocusNode();
    _summaryFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    _summaryController.dispose();
    _transcriptionFocusNode.dispose();
    _summaryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECFEFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E63)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          _isEditing ? '编辑笔记' : '笔记详情',
          style: const TextStyle(
            color: Color(0xFF164E63),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _buildActions(),
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
            if (widget.memo.status == 'completed' && widget.memo.structuredSummary != null) ...[
              _buildStructuredSummary(),
              const SizedBox(height: 20),
            ],
            if (widget.memo.status == 'completed') ...[
              _buildSummary(),
              const SizedBox(height: 20),
            ],
            if (widget.memo.status == 'completed') ...[
              _buildTags(),
              const SizedBox(height: 20),
            ],
            if (widget.memo.status == 'completed' && widget.memo.moodLabel != null) ...[
              _buildMood(),
              const SizedBox(height: 20),
            ],
            _buildRelatedMemos(),
            const SizedBox(height: 20),
            _buildAudioPlayer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_isSaving) {
      return [
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
        ),
      ];
    }

    if (_isEditing) {
      return [
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF164E63)),
          onPressed: _cancelEdit,
          tooltip: '取消编辑',
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Color(0xFF059669)),
          onPressed: _saveChanges,
          tooltip: '保存修改',
        ),
      ];
    }

    if (_isDeleting) {
      return [
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
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.edit_outlined, color: Color(0xFF164E63)),
        onPressed: _startEdit,
        tooltip: '编辑',
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: Color(0xFF164E63)),
        onPressed: () => _showDeleteDialog(context),
        tooltip: '删除',
      ),
    ];
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
          if (_isEditing)
            TextField(
              controller: _transcriptionController,
              focusNode: _transcriptionFocusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '输入转录文本...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF0891B2).withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF0891B2).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF164E63),
              ),
            )
          else if (widget.memo.transcription != null && widget.memo.transcription!.isNotEmpty)
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

  Widget _buildStructuredSummary() {
    final structured = widget.memo.structuredSummary!;
    final hasContent = structured.coreMessage != null ||
        structured.keyPoints.isNotEmpty ||
        structured.actionItems.isNotEmpty ||
        structured.topics.isNotEmpty;

    if (!hasContent) return const SizedBox.shrink();

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
                  Icons.auto_awesome,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI 智能分析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 核心信息
          if (structured.coreMessage != null && structured.coreMessage!.isNotEmpty) ...[
            _buildSummaryItem(
              icon: Icons.lightbulb_outline,
              iconColor: Color(0xFFF59E0B),
              title: '核心信息',
              content: structured.coreMessage!,
              isHighlighted: true,
            ),
            const SizedBox(height: 12),
          ],

          // 关键点
          if (structured.keyPoints.isNotEmpty) ...[
            _buildSummaryList(
              icon: Icons.check_circle_outline,
              iconColor: Color(0xFF059669),
              title: '关键点',
              items: structured.keyPoints,
            ),
            const SizedBox(height: 12),
          ],

          // 行动项
          if (structured.actionItems.isNotEmpty) ...[
            _buildSummaryList(
              icon: Icons.task_alt,
              iconColor: Color(0xFF0891B2),
              title: '行动项',
              items: structured.actionItems,
              showCheckboxes: true,
            ),
            const SizedBox(height: 12),
          ],

          // 主题
          if (structured.topics.isNotEmpty) ...[
            _buildTopicChips(structured.topics),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFF59E0B).withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFFF59E0B).withOpacity(0.3)
              : Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                    color: const Color(0xFF164E63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryList({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    bool showCheckboxes = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCheckboxes)
                    Icon(
                      Icons.check_box_outline_blank,
                      size: 18,
                      color: const Color(0xFF0891B2).withOpacity(0.5),
                    )
                  else
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 18,
                        color: iconColor.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF164E63),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTopicChips(List<String> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.tag,
              color: Color(0xFF8B5CF6),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '主题',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((topic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                topic,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
          if (_isEditing)
            TextField(
              controller: _summaryController,
              focusNode: _summaryFocusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '输入摘要...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF059669).withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF059669).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF164E63),
              ),
            )
          else
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
          if (_isEditing)
            _buildTagEditor()
          else
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

  Widget _buildTagEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _editedTags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _editedTags.remove(tag);
                });
              },
              backgroundColor: const Color(0xFF22D3EE).withOpacity(0.3),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF164E63),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: '添加新标签...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF8B5CF6).withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF8B5CF6).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
              onPressed: _addNewTag,
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _editedTags.add(value.trim());
              });
            }
          },
        ),
      ],
    );
  }

  void _addNewTag() {
    // 这里可以添加逻辑来打开一个对话框让用户输入标签
    // 目前简化处理，直接显示一个对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '添加标签',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF164E63),
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: '输入标签名称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            if (value.trim().isNotEmpty) {
              setState(() {
                _editedTags.add(value.trim());
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以获取TextField的值，但简化起见我们暂时跳过
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
            ),
            child: const Text('添加'),
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

  Widget _buildRelatedMemos() {
    return FutureBuilder<List<Memo>>(
      future: Provider.of<ApiService>(context, listen: false)
          .getRelatedMemos(widget.memo.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final relatedMemos = snapshot.data!;

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
                      Icons.link,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '相关笔记',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...relatedMemos.map((relatedMemo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRelatedMemoCard(relatedMemo),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRelatedMemoCard(Memo memo) {
    final tag = memo.tags.isNotEmpty ? memo.tags.first : '未分类';
    final tagColor = _getTagColor(tag);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoDetailScreen(memo: memo),
          ),
        ).then((result) {
          if (result == true && mounted) {
            // 如果相关笔记被删除或修改，刷新当前页面
            Navigator.pop(context, true);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8B5CF6),
                    const Color(0xFF8B5CF6).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
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
                          fontSize: 11,
                          color: const Color(0xFF164E63).withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 4),
                  Text(
                    memo.summary ?? memo.transcription ?? '暂无内容',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF164E63),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
            ),
          ],
        ),
      ),
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
    };

    return colors[tag] ?? const Color(0xFF0891B2);
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

  void _startEdit() {
    setState(() {
      _isEditing = true;
      // 初始化编辑器内容
      _transcriptionController.text = widget.memo.transcription ?? '';
      _summaryController.text = widget.memo.summary ?? '';
      _editedTags = List<String>.from(widget.memo.tags);
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // 恢复原始内容
      _transcriptionController.text = widget.memo.transcription ?? '';
      _summaryController.text = widget.memo.summary ?? '';
      _editedTags = List<String>.from(widget.memo.tags);
    });
  }

  Future<void> _saveChanges() async {
    // 隐藏键盘
    _transcriptionFocusNode.unfocus();
    _summaryFocusNode.unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // 调用API更新
      final updatedMemo = await apiService.updateMemo(
        widget.memo.id,
        transcription: _transcriptionController.text.trim().isEmpty
            ? null
            : _transcriptionController.text.trim(),
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
        tags: _editedTags,
      );

      if (mounted) {
        // 更新widget.memo
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        // 显示成功提示
        ErrorHandler.showSuccess(
          context: context,
          message: '笔记已更新',
        );

        // 返回更新后的memo，触发列表刷新
        Navigator.pop(context, updatedMemo);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        final errorType = ErrorHandler.detectErrorType(e);
        ErrorHandler.showError(
          context: context,
          type: errorType == ErrorType.unknown ? ErrorType.upload : errorType,
          customMessage: '保存失败: ${e.toString()}',
          onRetry: _saveChanges,
        );
      }
    }
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
              Navigator.pop(context);
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
      await Provider.of<ApiService>(context, listen: false).deleteMemo(widget.memo.id);

      if (mounted) {
        ErrorHandler.showSuccess(
          context: context,
          message: '笔记已删除',
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        final errorType = ErrorHandler.detectErrorType(e);
        ErrorHandler.showError(
          context: context,
          type: errorType,
          customMessage: '删除失败: ${e.toString()}',
          onRetry: _deleteMemo,
        );
      }
    }
  }
}
