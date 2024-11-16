import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tripify/models/post_model.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to create a new post
  Future<void> createPost(String userId, Post post, List<File> images) async {
    try {
      // Upload images and get their URLs
      List<String> mediaUrls = [];

      for (var image in images) {
        String imageUrl = await _uploadImage(image, userId);
        mediaUrls.add(imageUrl);
      }

      // Create the post map with the image URLs
      final postData = post.copyWith(media: mediaUrls).toMap();

      // Add the post data to Firestore
      await _firestore.collection('Post').add(postData);

      // Optionally, notify listeners or return a success message
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Method to upload an image to Firebase Storage and return the URL
  Future<String> _uploadImage(File image, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${userId}/media/${DateTime.now().millisecondsSinceEpoch}');

      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() {});
      
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
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
