import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId; // User ID referencing the User document
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> media;
  int likesCount;
  int commentsCount;
  int savedCount;

  // Constructor
  Post({
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.savedCount,
  });

  // Method to convert a Post object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'media': media, // Store media as an array of URLs
      'like_count': likesCount,
      'comment_count': commentsCount,
      'saved_count': savedCount,
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
      media: List<String>.from(data['media'] ?? []), // Handle media array
      likesCount: data['like_count'] ?? 0,
      commentsCount: data['comment_count'] ?? 0,
      savedCount: data['saved_count'] ?? 0,
    );
  }

  Post copyWith({
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? media,
    int? likesCount,
    int? commentsCount,
    int? savedCount,
  }) {
    return Post(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savedCount: savedCount ?? this.savedCount,
    );
  }
}
