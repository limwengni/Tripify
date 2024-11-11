import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  // Private constructor
  FirestoreService._internal();

  // Factory constructor to return the singleton instance
  factory FirestoreService() {
    return _instance;
  }

  // Get the Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserTheme(String uid, bool isDarkMode) async {
    try {
      await _db.collection('User').doc(uid).update({
        'theme': isDarkMode ? 'dark' : 'light',
      });
      print("User theme updated successfully.");
    } catch (e) {
      print("Error saving theme: $e");
    }
  }

  Future<String> getUserTheme(String uid) async {
    try {
      // Fetch the user document from Firestore
      var userDoc = await _db.collection('User').doc(uid).get();

      // Check if the document exists and if the 'theme' field is available
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()?['theme'] ??
            'light'; // Return theme or default to 'light'
      } else {
        // Return 'light' if the document doesn't exist or has no 'theme' field
        return 'light';
      }
    } catch (e) {
      print("Error fetching user theme: $e");
      return 'light'; // In case of any error, default to 'light'
    }
  }

  // Insert Data (General)
  Future<void> insertData(String collection, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).add(data);
      print("Data inserted successfully.");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  // Insert user data
  Future<void> insertUserData(
      String collection, Map<String, dynamic> data) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String theme = 'light'; // Default theme

      // Add theme to the data map
      data['theme'] = theme;

      // Use the UID as the document ID in Firestore
      await _db.collection(collection).doc(uid).set(data);
      print("User data inserted successfully.");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  // Update Data
  Future<void> updateData(
      String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(documentId).update(data);
      print("Data updated successfully.");
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  // Delete Data
  Future<void> deleteData(String collection, String documentId) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
      print("Data deleted successfully.");
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  // Select Data (Get All)
  Future<List<Map<String, dynamic>>> getData(String collection) async {
    try {
      final querySnapshot = await _db.collection(collection).get();
      List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        dataList.add(doc.data() as Map<String, dynamic>);
      }
      return dataList;
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  // Select Data (Get by Document ID)
  Future<Map<String, dynamic>?> getDataById(
      String collection, String documentId) async {
    try {
      final docSnapshot =
          await _db.collection(collection).doc(documentId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print("Document not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }

// Select Data (Get by Field Value)
  Future<List<Map<String, dynamic>>> getDataByField(
      String collection, String field, dynamic value) async {
    try {
      final querySnapshot =
          await _db.collection(collection).where(field, isEqualTo: value).get();
      List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        dataList.add(doc.data() as Map<String, dynamic>);
      }
      return dataList;
    } catch (e) {
      print("Error fetching data by field: $e");
      return [];
    }
  }
}
