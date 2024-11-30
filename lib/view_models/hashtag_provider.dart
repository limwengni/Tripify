import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/hashtag_model.dart';

class HashtagProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a hashtag or update usage count
  Future<void> addHashtag(String hashtagName) async {
    try {
      final querySnapshot = await _firestore
          .collection('Hashtag')
          .where('name', isEqualTo: hashtagName.toLowerCase())
          .get();

      if (querySnapshot.docs.isEmpty) {
        final newHashtag = Hashtag(
          name: hashtagName.toLowerCase(),
          usageCount: 1,
        );

        await _firestore.collection('Hashtag').add(newHashtag.toMap());
      } else {
        final doc = querySnapshot.docs.first;
        int currentUsageCount = doc['usage_count'];

        final updatedHashtag = Hashtag(
          id: doc.id,
          name: hashtagName,
          usageCount: currentUsageCount + 1,
        );

        await doc.reference.update(updatedHashtag.toMap());
      }
    } catch (e) {
      print("Error adding/updating hashtag: $e");
    }
  }

  Future<List<Hashtag>> getHashtags({DocumentSnapshot? lastDocument}) async {
    try {
      Query query = _firestore
          .collection('Hashtag')
          .orderBy('usage_count',
              descending: true) // Most popular to least popular
          .limit(20); // Fetch 20 hashtags

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      List<Hashtag> hashtags =
          querySnapshot.docs.map((doc) => Hashtag.fromFirestore(doc)).toList();

      // Randomize the results
      hashtags.shuffle();

      return hashtags;
    } catch (e) {
      print("Error retrieving hashtags: $e");
      return [];
    }
  }
}
