class Memo {
  final int id;
  final String audioPath;
  final String? transcription;
  final String? summary;
  final List<String> tags;
  final double? moodScore;
  final String? moodLabel;
  final String status;
  final DateTime createdAt;

  Memo({
    required this.id,
    required this.audioPath,
    this.transcription,
    this.summary,
    required this.tags,
    this.moodScore,
    this.moodLabel,
    required this.status,
    required this.createdAt,
  });

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'],
      audioPath: json['audio_path'],
      transcription: json['transcription'],
      summary: json['summary'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      moodScore: json['mood_score']?.toDouble(),
      moodLabel: json['mood_label'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
