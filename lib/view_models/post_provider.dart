import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tripify/models/hashtag_model.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/models/comment_model.dart';
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

  Future<List<Map<String, dynamic>>> fetchRecommendedPosts(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch the posts the user has already liked
      final likedPostsSnapshot = await _firestore
          .collection('PostLike')
          .where('user_id', isEqualTo: uid)
          .get();

      // Extract liked post IDs
      final likedPostIds = likedPostsSnapshot.docs
          .map((doc) => doc['post_id'] as String)
          .toList();

      // Collect hashtags from the liked posts
      final likedHashtags = <String>{};
      for (final postId in likedPostIds) {
        final postSnapshot =
            await _firestore.collection('Post').doc(postId).get();
        if (postSnapshot.exists) {
          final hashtags = (postSnapshot.data()?['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();
          if (hashtags != null) {
            likedHashtags.addAll(hashtags);
          }
        }
      }

      // Fetch all posts except the ones already liked and created by the user
      final snapshot = await _firestore
          .collection('Post')
          .where('user_id', isNotEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Filter posts based on hashtags and exclude already liked ones
        final recommendedPosts = snapshot.docs
            .where((doc) =>
                !likedPostIds.contains(doc.id) &&
                (doc.data()['hashtags'] as List<dynamic>?)
                        ?.any((hashtag) => likedHashtags.contains(hashtag)) ==
                    true)
            .map((doc) => {
                  'id': doc.id,
                  'post': Post.fromMap(doc.data()),
                })
            .toList();

        // Shuffle recommendations to provide variety
        recommendedPosts.shuffle();

        _userPosts = recommendedPosts.map((e) => e['post'] as Post).toList();
        _id = recommendedPosts.map((e) => e['id'] as String).toList();

        notifyListeners();
        return recommendedPosts;
      } else {
        _userPosts = [];
        notifyListeners();
        return [];
      }
    } catch (e) {
      print("Error fetching recommended posts: $e");
      throw Exception('Failed to fetch recommended posts: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<List<Map<String, dynamic>>> fetchPostsForAllUsersExceptLoggedIn(
  //     String uid) async {
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     // Fetch all posts except the ones belonging to the logged-in user
  //     final snapshot = await _firestore
  //         .collection('Post')
  //         .where('user_id',
  //             isNotEqualTo: uid)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       // Convert Firestore docs to a list of maps containing post data and post ID
  //       final postsWithIds = snapshot.docs
  //           .where((doc) => doc.exists)
  //           .map((doc) => {
  //                 'id': doc.id,
  //                 'post': Post.fromMap(doc.data()),
  //               })
  //           .toList();

  //       _userPosts = postsWithIds.map((e) => e['post'] as Post).toList();
  //       _id = postsWithIds.map((e) => e['id'] as String).toList();

  //       // Randomize the posts for recommender
  //       postsWithIds.shuffle();

  //       notifyListeners();
  //       return postsWithIds;
  //     } else {
  //       _userPosts = [];
  //       notifyListeners();
  //       return [];
  //     }
  //   } catch (e) {
  //     print("Error fetching posts: $e");
  //     throw Exception('Failed to fetch posts: $e');
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchPostsForLoginUser(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('Post')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true) // Latest to oldest post
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

  Future<Post> fetchPostById(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await _firestore.collection('Post').doc(postId).get();

      if (postSnapshot.exists) {
        // Convert the snapshot into a Post object
        return Post.fromMap(postSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Failed to load post: $e');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postLikeDoc =
          await _firestore.collection('PostLike').doc('$userId-$postId').get();

      if (postLikeDoc.exists) {
        // If the document exists, it means the user already liked the post
        await _firestore.collection('PostLike').doc('$userId-$postId').delete();

        await _firestore.collection('Post').doc(postId).update({
          'like_count': FieldValue.increment(-1),
        });

        final postDoc = await _firestore.collection('Post').doc(postId).get();
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          await _updateUserLikesCount(postData['user_id'], -1);
          print("User's like count updated.");
        }
      } else {
        // If the document does not exist, it means the user has not liked the post yet
        await _firestore.collection('PostLike').doc('$userId-$postId').set({
          'user_id': userId,
          'post_id': postId,
          'created_at': Timestamp.now(),
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
        print("cant update likes_count");
      }
    } catch (e) {
      print("Error updating user likes count: $e");
    }
  }

  Future<List<PostComment>> fetchCommentsForPost(String postId) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('PostComment')
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final comments = snapshot.docs
            .where((doc) => doc.exists)
            .map((doc) => PostComment.fromFirestore(doc))
            .toList();

        notifyListeners();
        return comments;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching comments: $e");
      throw Exception('Failed to fetch comments: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadComment(PostComment comment, BuildContext context) async {
    try {
      CollectionReference commentsRef = _firestore.collection('PostComment');

      await commentsRef.add(comment.toMap());

      DocumentReference postRef =
          _firestore.collection('Post').doc(comment.postId);
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        String postUserId = postSnapshot['user_id'];

        // Now update the comment count for the post's user
        await updatePostCommentCount(comment.postId, 1, postUserId);
      } else {
        print("Post not found!");
      }
    } catch (e) {
      print("Error uploading comment: $e");
    }
  }

  Future<void> deleteComment(String commentId, String postId, String userId,
      BuildContext context) async {
    try {
      await _firestore.collection('PostComment').doc(commentId).delete();

      final postDoc = await _firestore.collection('Post').doc(postId).get();

      if (postDoc.exists) {
        final posterId = postDoc.data()?['user_id'];

        // Update the post's comment count (decrease by 1)
        await updatePostCommentCount(postId, -1, posterId);
      } else {
        print("Post not found.");
      }
    } catch (e) {
      print("Error deleting comment: $e");
      throw e;
    }
  }

  Future<void> _updateUserCommentCount(String userId, int increment) async {
    try {
      // Update the comment count in the user's document
      final userDoc = await _firestore.collection('User').doc(userId).get();

      if (userDoc.exists) {
        await _firestore.collection('User').doc(userId).update({
          'comments_count': FieldValue.increment(increment),
        });
      } else {
        print("Can't update comment_count for the user");
      }
    } catch (e) {
      print("Error updating user comment count: $e");
    }
  }

  Future<void> updatePostCommentCount(
      String postId, int increment, String userId) async {
    try {
      // Update the comment count in the post document
      await _firestore.collection('Post').doc(postId).update({
        'comment_count': FieldValue.increment(increment),
      });

      // Update the user's comment count
      await _updateUserCommentCount(userId, increment);
    } catch (e) {
      print("Error updating post or user comment count: $e");
    }
  }

  // You can add more methods for updating and deleting posts as needed
}
