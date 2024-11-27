import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tripify/models/hashtag_model.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/view_models/hashtag_provider.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<Post> _userPosts = [];

  List<Post> get userPosts => _userPosts;

  // Method to create a new post
  Future<void> submitPost({
    required String userId,
    required String title,
    String? description,
    required Map<File, int> mediaWithIndex,
    List<String>? hashtags,
    String? location,
  }) async {
    try {
      List<String> mediaUrls = await _uploadMedia(mediaWithIndex, userId);
      HashtagProvider hashtagProvider = new HashtagProvider();

      if (hashtags != null && hashtags.isNotEmpty) {
        for (String hashtag in hashtags) {
          await hashtagProvider.addHashtag(hashtag);
        }
      }

      Post newPost = Post(
        userId: userId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: null,
        media: mediaUrls,
        hashtags: hashtags,
        location: location,
        likesCount: 0,
        commentsCount: 0,
        savedCount: 0,
      );

      await _firestore.collection('Post').add(newPost.toMap());
    } catch (e) {
      print("Error submitting post: $e");
    }
  }

  Future<List<String>> _uploadMedia(
      Map<File, int> mediaWithIndex, String userId) async {
    List<String> mediaUrls = [];

    try {
      for (var entry in mediaWithIndex.entries) {
        File mediaFile = entry.key;
        String fileName = mediaFile.uri.pathSegments.last;
        String fileExtension = fileName.split('.').last.toLowerCase();

        Reference mediaRef =
            FirebaseStorage.instance.ref().child('${userId}/media/$fileName');

        UploadTask uploadTask = mediaRef.putFile(mediaFile);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        mediaUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Error uploading image: $e');
    }

    return mediaUrls;
  }

  Future<void> fetchPostsForLoginUser(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('Post')
          .where('user_id', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _userPosts = snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => Post.fromMap(doc.data()))
            .toList();
      } else {
        _userPosts = [];
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching user posts: $e");
      throw Exception('Failed to fetch posts: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postLikeDoc = await _firestore
          .collection('PostLike')
          .doc(
              '$userId-$postId') // This document represents the user's like on this post
          .get();

      if (postLikeDoc.exists) {
        // If the document exists, it means the user already liked the post
        // "unlike" it: delete the like entry and update the like count
        await _firestore.collection('PostLike').doc('$userId-$postId').delete();

        // Decrease the like count in the Post collection
        await _firestore.collection('Post').doc(postId).update({
          'like_count': FieldValue.increment(-1),
        });

        // Decrease the owner's likes count (in the User collection)
        final postDoc = await _firestore.collection('Post').doc(postId).get();
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          await _updateUserLikesCount(postData['userId'], -1);
        }
      } else {
        // If the document does not exist, it means the user has not liked the post yet
        // "like" the post: add an entry to the PostLike table and update the like count
        await _firestore.collection('PostLike').doc('$userId-$postId').set({
          'userId': userId,
          'postId': postId,
        });

        // Increase the like count in the Post collection
        await _firestore.collection('Post').doc(postId).update({
          'like_count': FieldValue.increment(1),
        });

        // Increase the owner's likes count (in the User collection)
        final postDoc = await _firestore.collection('Post').doc(postId).get();
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          await _updateUserLikesCount(postData['userId'], 1);
        }
      }
    } catch (e) {
      print("Error liking/unliking post: $e");
    }
  }

  Future<void> _updateUserLikesCount(String userId, int increment) async {
    try {
      // Update the likes count in the user's document
      final userDoc = await _firestore.collection('User').doc(userId).get();

      if (userDoc.exists) {
        await _firestore.collection('User').doc(userId).update({
          'likes_count': FieldValue.increment(increment),
        });
      }
    } catch (e) {
      print("Error updating user likes count: $e");
    }
  }

  // You can add more methods for updating and deleting posts as needed
}
