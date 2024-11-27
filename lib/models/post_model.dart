import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId; // User ID referencing the User document
  final String title;
  final String? description;
  final DateTime createdAt;
  DateTime? updatedAt;
  final List<String> media;
  List<String>? hashtags;
  String? location;
  int likesCount;
  int commentsCount;
  int savedCount;

  // Constructor
  Post({
    required this.userId,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    required this.media,
    this.hashtags,
    this.location,
    required this.likesCount,
    required this.commentsCount,
    required this.savedCount,
  });

  // Method to convert a Post object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'created_at': Timestamp.fromDate(DateTime.now()),
      'updated_at': null,
      'media': media,
      'hashtags': hashtags,
      'location': location,
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
      description: data['description'] ?? '',
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : (data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null),
      media: List<String>.from(data['media'] ?? []), // Handle media array
      hashtags: List<String>.from(data['hashtags'] ?? []),
      location: data['location'] ?? '',
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
    List<String>? hashtags,
    String? location,
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
      hashtags: hashtags ?? this.hashtags,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savedCount: savedCount ?? this.savedCount,
    );
  }
}
