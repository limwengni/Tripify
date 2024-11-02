import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/post_model.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to create a new post
  Future<void> createPost(Post post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Method to fetch all posts
  Future<List<Post>> fetchPosts() async {
    try {
      final snapshot = await _firestore.collection('posts').get();
      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // You can add more methods for updating and deleting posts as needed
}
