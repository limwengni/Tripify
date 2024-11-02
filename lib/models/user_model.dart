import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username;
  final String? ssm;
  String bio;
  String profilePic;
  final DateTime birthdate;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String uid;
  int likesCount;
  int commentsCount;
  int savedCount;

  UserModel({
    required this.username,
    this.ssm,
    required this.bio,
    required this.profilePic,
    required this.birthdate,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.likesCount,
    required this.commentsCount,
    required this.savedCount,
  });

  // Method to convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'SSM': ssm,
      'bio': bio,
      'profile_picture': profilePic,
      'birthdate': birthdate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'saved_count': savedCount,
    };
  }

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      username: data['username'] ?? 'Unknown User',
      ssm: data['SSM'] ?? '',
      bio: data['bio'] ?? 'No bio available.',
      profilePic: data['profile_picture'] ?? '',
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
      uid: uid,
      likesCount: data['likes_count'] ?? 0,
      commentsCount: data['comments_count'] ?? 0,
      savedCount: data['saved_count'] ?? 0,
    );
  }
}
