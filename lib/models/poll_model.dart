import 'package:cloud_firestore/cloud_firestore.dart';

class PollModel {
  final String id;
  final DateTime createdAt;
  final DateTime endAt;
  final List<String> options; // List of options as strings
  final String question;
  final Map<String, int>? answers; // User ID mapped to chosen option index
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
      endAt: (data['end_at'] is Timestamp)
          ? (data['end_at'] as Timestamp).toDate()
          : DateTime.parse(data['end_at']),
      options: List<String>.from(data['options']),
      question: data['question'] as String,
      answers: data['answers'] != null
          ? Map<String, int>.from(data['answers'] as Map)
          : null,
    );
  }

  /// Converts PollModel to a Map (e.g., for Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_by': createdBy,
      'created_at': createdAt,
      'end_at': endAt,
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
    return answers?.length ?? 0;
  }

  /// Returns the percentage of votes for each option
  Map<int, double> calculateVotePercentages() {
    final int total = totalVotes();
    if (total == 0) return {for (int i = 0; i < options.length; i++) i: 0.0};

    final Map<int, double> percentages = {};
    for (int i = 0; i < options.length; i++) {
      final int votes =
          answers?.values.where((value) => value == i).length ?? 0;
      percentages[i] = (votes / total) * 100;
    }
    return percentages;
  }
}
