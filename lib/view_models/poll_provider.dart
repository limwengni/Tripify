import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PollProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to check if the user has voted on a specific poll
  Future<String?> getUserSelectedOption(String postId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('PollInteraction')
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the selected option
        return querySnapshot.docs.first['selected_option'];
      } else {
        // User has not voted
        return null;
      }
    } catch (e) {
      print("Error checking if user has voted: $e");
      return null;
    }
  }

  Future<void> submitPollInteraction(
      String postId, String selectedOption) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("User is not authenticated");
        return;
      }

      // Create a poll interaction document
      await FirebaseFirestore.instance.collection('PollInteraction').add({
        'user_id': userId,
        'post_id': postId,
        'selected_option': selectedOption,
        'created_at': DateTime.now(),
      });

      print("Poll interaction submitted successfully!");
    } catch (e) {
      print("Error submitting poll interaction: $e");
    }
  }

  Future<Map<String, int>> getPollResults(String pollId) async {
    try {
      // Fetch all interactions for the specific pollId
      final snapshot = await FirebaseFirestore.instance
          .collection('PollInteraction')
          .where('post_id', isEqualTo: pollId)
          .get();

      Map<String, int> results = {};

      // Count the occurrences of each option
      for (var doc in snapshot.docs) {
        String selectedOption = doc['selected_option'];
        if (results.containsKey(selectedOption)) {
          results[selectedOption] = results[selectedOption]! + 1;
        } else {
          results[selectedOption] = 1;
        }
      }

      return results;
    } catch (e) {
      print("Error fetching poll results: $e");
      return {};
    }
  }

  Future<void> clearUserVote(String postId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('PollInteraction')
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print("Vote cleared successfully");
    } catch (e) {
      print("Error clearing vote: $e");
    }
  }
}
