import 'package:cloud_firestore/cloud_firestore.dart';

class PollModel {
  final String id;
  final DateTime createdAt;
  final DateTime endAt;
  final Map<int, String> options; // Option ID mapped to its description
  final String question; 
  final Map<String, int>? answers; // User ID mapped to chosen option ID
  final String createdBy;

  PollModel({
    required this.createdBy, 
    required this.id,
    required this.createdAt,
    required this.endAt,
    required this.options,
    required this.question,
    required this.answers,
  });

  /// Factory constructor to create a PollModel from a Map (e.g., from Firestore or JSON)
  factory PollModel.fromMap(Map<String, dynamic> data) {
    return PollModel(
      id: data['id'] as String,
      createdBy: data['created_by'],
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['create_at']),
      endAt:  (data['end_at'] is Timestamp)
          ? (data['end_at'] as Timestamp).toDate()
          : DateTime.parse(data['end_at']),
      options: Map<int, String>.from(data['options'] as Map),
      question: data['question'] as String,
      answers: Map<String, int>.from(data['answers'] as Map),
    );
  }

  /// Converts PollModel to a Map (e.g., for Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'options': options,
      'question': question,
      'answers': answers,
    };
  }

  /// Checks if the poll is still active
  bool isActive() {
    return DateTime.now().isBefore(endAt);
  }

  /// Calculates the total votes for the poll
  int totalVotes() {
    return answers!.length;
  }

  /// Returns the percentage of votes for each option
  Map<int, double> calculateVotePercentages() {
    final int total = totalVotes();
    if (total == 0) return options.map((key, _) => MapEntry(key, 0.0));

    final Map<int, double> percentages = {};
    for (final entry in options.entries) {
      final int votes = answers!.values.where((value) => value == entry.key).length;
      percentages[entry.key] = (votes / total) * 100;
    }
    return percentages;
  }
}
