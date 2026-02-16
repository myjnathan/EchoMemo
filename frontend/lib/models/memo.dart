class Memo {
  final int id;
  final String audioPath;
  final String? transcription;
  final String? summary;
  final StructuredSummary? structuredSummary; // Phase 2: 结构化摘要
  final List<String> tags;
  final double? moodScore;
  final String? moodLabel;
  final String status;
  final List<double>? embedding; // Phase 2: 文本嵌入向量
  final List<int>? relatedMemoIds; // Phase 2: 相关笔记ID
  final DateTime createdAt;
  final DateTime? updatedAt;

  Memo({
    required this.id,
    required this.audioPath,
    this.transcription,
    this.summary,
    this.structuredSummary,
    required this.tags,
    this.moodScore,
    this.moodLabel,
    required this.status,
    this.embedding,
    this.relatedMemoIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'],
      audioPath: json['audio_path'],
      transcription: json['transcription'],
      summary: json['summary'],
      structuredSummary: json['structured_summary'] != null
          ? StructuredSummary.fromJson(json['structured_summary'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      moodScore: json['mood_score']?.toDouble(),
      moodLabel: json['mood_label'],
      status: json['status'],
      embedding: json['embedding'] != null
          ? List<double>.from(json['embedding'].map((e) => e.toDouble()))
          : null,
      relatedMemoIds: json['related_memo_ids'] != null
          ? List<int>.from(json['related_memo_ids'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class StructuredSummary {
  final String? coreMessage;
  final List<String> keyPoints;
  final List<String> actionItems;
  final List<String> topics;

  StructuredSummary({
    this.coreMessage,
    List<String>? keyPoints,
    List<String>? actionItems,
    List<String>? topics,
  })  : keyPoints = keyPoints ?? [],
        actionItems = actionItems ?? [],
        topics = topics ?? [];

  factory StructuredSummary.fromJson(Map<String, dynamic> json) {
    return StructuredSummary(
      coreMessage: json['core_message'],
      keyPoints: json['key_points'] != null
          ? List<String>.from(json['key_points'])
          : [],
      actionItems: json['action_items'] != null
          ? List<String>.from(json['action_items'])
          : [],
      topics: json['topics'] != null
          ? List<String>.from(json['topics'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'core_message': coreMessage,
      'key_points': keyPoints,
      'action_items': actionItems,
      'topics': topics,
    };
  }
}
