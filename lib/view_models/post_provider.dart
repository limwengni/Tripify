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
  List<String> _id = [];

  List<Post> get userPosts => _userPosts;
  List<String> get postsId => _id;

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

  Future<List<Map<String, dynamic>>> fetchPostsForAllUsersExceptLoggedIn(
      String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch all posts except the ones belonging to the logged-in user
      final snapshot = await _firestore
          .collection('Post')
          .where('user_id',
              isNotEqualTo: uid) // Exclude posts from the logged-in user
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Convert Firestore docs to a list of maps containing post data and post ID
        final postsWithIds = snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'post': Post.fromMap(doc.data()), // Post object
                })
            .toList();

        _userPosts = postsWithIds.map((e) => e['post'] as Post).toList();
        _id = postsWithIds.map((e) => e['id'] as String).toList();

        // Randomize the posts for recommender
        postsWithIds.shuffle(); // Shuffle the posts to randomize them

        notifyListeners();
        return postsWithIds;
      } else {
        _userPosts = [];
        notifyListeners();
        return [];
      }
    } catch (e) {
      print("Error fetching posts: $e");
      throw Exception('Failed to fetch posts: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> fetchPostsForLoginUser(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('Post')
          .where('user_id', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final postsWithIds = snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'post': Post.fromMap(doc.data()), // Post object
                })
            .toList();

        _userPosts = postsWithIds.map((e) => e['post'] as Post).toList();
        _id = postsWithIds.map((e) => e['id'] as String).toList();

        notifyListeners();
        return postsWithIds;
      } else {
        _userPosts = [];
        notifyListeners();
        return [];
      }
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
        await _firestore.collection('PostLike').doc('$userId-$postId').delete();

        // Decrease the like count in the Post collection
        await _firestore.collection('Post').doc(postId).update({
          'like_count': FieldValue.increment(-1),
        });

        // Decrease the owner's likes count (in the User collection)
        final postDoc = await _firestore.collection('Post').doc(postId).get();
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          await _updateUserLikesCount(postData['user_id'], -1);
          print("User's like count updated.");
        }
      } else {
        // If the document does not exist, it means the user has not liked the post yet
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
          await _updateUserLikesCount(postData['user_id'], 1);
        }
      }
    } catch (e) {
      print("Error liking/unliking post: $e");
    }
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      // Check if the user has liked the post
      final doc = await _firestore
          .collection('PostLike')
          .doc('$userId-$postId') // Use the correct document ID format
          .get();
      return doc.exists;
    } catch (e) {
      print("Error checking like status: $e");
      return false;
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
      } else {
        print("cnt update likes_cpunt");
      }
    } catch (e) {
      print("Error updating user likes count: $e");
    }
  }

  // You can add more methods for updating and deleting posts as needed
}
