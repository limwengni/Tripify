import 'package:cloud_firestore/cloud_firestore.dart';

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  // Factory method to create a PostComment from Firestore document
  factory PostComment.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return PostComment(
      id: doc.id,
      postId: data['post_id'] ?? '',
      userId: data['user_id'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
    );
  }

  // Convert PostComment to a Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'user_id': userId,
      'text': text,
      'created_at': Timestamp.fromDate(DateTime.now()),
    };
  }
}
