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
  Future<bool> isUserVoted(String postId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('PollInteraction')
          .where('post_id', isEqualTo: postId)
          .where('user_id', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if user has voted: $e");
      return false;
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
        String selectedOption = doc['selectedOption'];
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
}
