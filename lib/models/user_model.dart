import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username;
  final String role;
  final String? ssm;
  final String? ssmDownloadUrl;
  String bio;
  String profilePic;
  final DateTime birthdate;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String uid;
  int likesCount;
  int commentsCount;
  int savedCount;
  double? walletCredit;
  double? cashoutAmount;

  UserModel({
    required this.username,
    required this.role,
    this.ssm,
    this.ssmDownloadUrl,
    required this.bio,
    required this.profilePic,
    required this.birthdate,
    required this.createdAt,
    this.updatedAt,
    required this.uid,
    required this.likesCount,
    required this.commentsCount,
    required this.savedCount,
    this.walletCredit,
    this.cashoutAmount,
  });

  // Method to convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'role': role,
      'SSM': ssm,
      'SSM_URL': ssmDownloadUrl,
      'bio': bio,
      'profile_picture': profilePic,
      'birthdate': Timestamp.fromDate(birthdate),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': null,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'saved_count': savedCount,
      'id': uid,
      'wallet_credit': walletCredit,
      'cashout_amount': cashoutAmount,
    };
  }

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      username: data['username'] ?? 'Unknown User',
      role: data['role'],
      ssm: data['SSM'],
      ssmDownloadUrl: data['SSM_URL'] ?? '',
      bio: data['bio'] ?? 'No bio available.',
      profilePic: data['profile_picture'] ?? '',
      birthdate: (data['birthdate'] is Timestamp)
          ? (data['birthdate'] as Timestamp).toDate()
          : DateTime.parse(data['birthdate']),
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : (data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null),
      uid: uid,
      likesCount: data['likes_count'] ?? 0,
      commentsCount: data['comments_count'] ?? 0,
      savedCount: data['saved_count'] ?? 0,
      walletCredit: (data['wallet_credit'] is int)
          ? (data['wallet_credit'] as int).toDouble()
          : data['wallet_credit'],
  cashoutAmount: (data['cashout_amount'] is int)
          ? (data['cashout_amount'] as int).toDouble()
          : data['cashout_amount'],
    );
  }
}
