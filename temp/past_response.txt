class PastResponse {
  final String id;
  final DateTime createdAt;
  final List<Entry> entries;

  PastResponse({required this.id, required this.createdAt, required this.entries});

  factory PastResponse.fromJson(Map<String, dynamic> json) {
    return PastResponse(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      entries: (json['entries'] as List)
          .map((e) => Entry.fromJson(e))
          .toList(),
    );
  }
}
// lib/data/models/past_response.dart

class Entry {
  // Add these two nullable fields
  final String? id;
  final String? parentId;

  final DateTime questionTimestamp;
  final String question;
  final DateTime answerTimestamp;
  final String answer;

  Entry({
    this.id,
    this.parentId,
    required this.questionTimestamp,
    required this.question,
    required this.answerTimestamp,
    required this.answer,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      // Read the new fields from JSON
      id: json['id'],
      parentId: json['parentId'],
      questionTimestamp: DateTime.parse(json['questionTimestamp']),
      question: json['question'],
      answerTimestamp: DateTime.parse(json['answerTimestamp']),
      answer: json['answer'],
    );
  }
}