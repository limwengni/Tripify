import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId; // User ID referencing the User document
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Constructor
  Post({
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  // Method to convert a Post object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Factory method to create a Post object from Firestore data
  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      userId: data['user_id'],
      title: data['title'],
      description: data['description'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }
}
