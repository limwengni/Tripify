import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';

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

// Insert Data with Document ID as an Attribute
  Future<void> insertDataWithAutoID(
      String collection, Map<String, dynamic> data) async {
    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef = _db.collection(collection).doc();

      // Add the document ID to the data map
      data['id'] = docRef.id;

      // Insert the data into Firestore, including the document ID as an attribute
      await docRef.set(data);

      print("Data inserted successfully with document ID as an attribute.");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  Future<String> insertDataWithReturnAutoID(
      String collection, Map<String, dynamic> data) async {
    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef = _db.collection(collection).doc();

      // Add the document ID to the data map
      data['id'] = docRef.id;

      // Insert the data into Firestore, including the document ID as an attribute
      await docRef.set(data);

      print("Data inserted successfully with document ID as an attribute.");
      return docRef.id;
    } catch (e) {
      print("Error inserting data: $e");
    }
    return '';
  }

  Future<void> insertSubCollectionDataWithAutoID(String collection,
      String subCollection, String docId, Map<String, dynamic> data) async {
    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef =
          _db.collection(collection).doc(docId).collection(subCollection).doc();

      // Add the document ID to the data map
      data['id'] = docRef.id;

      // Insert the data into Firestore, including the document ID as an attribute
      await docRef.set(data);

      print("Data inserted successfully with document ID as an attribute.");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  Future<String> insertSubCollectionDataWithAutoIDReturnValue(String collection,
      String subCollection, String docId, Map<String, dynamic> data) async {
    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef =
          _db.collection(collection).doc(docId).collection(subCollection).doc();

      // Add the document ID to the data map
      data['id'] = docRef.id;

      // Insert the data into Firestore, including the document ID as an attribute
      await docRef.set(data);

      print("Data inserted successfully with document ID as an attribute.");
      return docRef.id;
    } catch (e) {
      print("Error inserting data: $e");
    }

    return "";
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

  Future<void> updateField(
      String collection, String documentId, String field, dynamic value) async {
    try {
      // Update the specified field in the Firestore document
      await _db.collection(collection).doc(documentId).update({
        field: value,
      });
      print("Field '$field' updated successfully.");
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  Future<void> updateMapField(String collection, String documentId,
      String field, String key, dynamic value) async {
    try {
      // Update the specific key in the map field
      await _db.collection(collection).doc(documentId).update({
        '$field.$key':
            value, // Access the key inside the map field and update its value
      });
      print("Field '$field' updated successfully for key '$key'.");
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  Future<void> removeMapKey(
      String collection, String documentId, String field, String key) async {
    try {
      // Use FieldValue.delete() to remove the specific key in the map field
      await _db.collection(collection).doc(documentId).update({
        '$field.$key': FieldValue.delete(),
      });
      print("Key '$key' removed successfully from field '$field'.");
    } catch (e) {
      print("Error removing key from field: $e");
    }
  }

  Future<void> updateSubCollectionField(
      {required String collection,
      required String documentId,
      required String subCollection,
      required String subDocumentId,
      required String field,
      required dynamic value}) async {
    try {
      // Update the specified field in the Firestore document
      await _db
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subDocumentId)
          .update({
        field: value,
      });
      print("Field '$field' updated successfully.");
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  Future<void> removeItemFromFirestoreList({
    required String collectionPath,
    required String documentId,
    required String fieldName,
    required dynamic itemToRemove,
  }) async {
    try {
      // Reference to the Firestore document
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection(collectionPath).doc(documentId);

      // Update the document by removing the specific item
      await documentRef.update({
        fieldName: FieldValue.arrayRemove([itemToRemove]),
      });

      print("Item removed successfully.");
    } catch (e) {
      print("Error removing item: $e");
    }
  }

  Future<void> addItemToSubCollectionList({
    required String documentId,
    required String collectionName,
    required String subDocumentId,
    required String subCollectionName,
    required String fieldName,
    required List<String> newItems,
  }) async {
    try {
      // Reference to the document
      DocumentReference documentRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .collection(subCollectionName)
          .doc(subDocumentId);

      // Update the list using arrayUnion to add the new item
      await documentRef.update({
        fieldName: FieldValue.arrayUnion(newItems),
      });

      print('Item added successfully to the list!');
    } catch (e) {
      print('Error adding item to the list: $e');
    }
  }

  Future<void> addItemToCollectionList({
    required String documentId,
    required String collectionName,
    required String fieldName,
    required List<String> newItems,
  }) async {
    try {
      // Reference to the document
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection(collectionName).doc(documentId);

      // Update the list using arrayUnion to add the new item
      await documentRef.update({
        fieldName: FieldValue.arrayUnion(newItems),
      });

      print('Item added successfully to the list!');
    } catch (e) {
      print('Error adding item to the list: $e');
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

 Future<List<Map<String, dynamic>>> getDataOrderBy(
    String collection, String? orderBy, bool descending) async {
  try {
    Query query = _db.collection(collection);
    if (orderBy != null && orderBy.isNotEmpty) {
      query = query.orderBy(orderBy, descending: descending);
    }
    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Error fetching data from $collection: $e");
    return [];
  }
}
Future<List<Map<String, dynamic>>> getSubCollectionDataOrderBy(
    String collection,
    String documentId,
    String subCollection,
    String? orderBy,
    bool descending,
  ) async {
  try {
    // Access the parent document
    final parentDocRef = _db.collection(collection).doc(documentId);

    // Build the subcollection query
    Query subCollectionQuery = parentDocRef.collection(subCollection);
    if (orderBy != null && orderBy.isNotEmpty) {
      subCollectionQuery = subCollectionQuery.orderBy(orderBy, descending: descending);
    }

    // Fetch data
    final querySnapshot = await subCollectionQuery.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Error fetching subcollection data: $e");
    return [];
  }
}


Stream<QuerySnapshot<Map<String, dynamic>>> getStreamData({
  required String collection,
  bool descending = false,
  String? orderBy,
}) {
  try {
    // Start with a reference to the collection
    CollectionReference<Map<String, dynamic>> collectionRef =
        _db.collection(collection);

    // Apply optional ordering
    Query<Map<String, dynamic>> query = collectionRef;
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Return the stream of snapshots
    return query.snapshots();
  } catch (e, stacktrace) {
    // Log the error with context and stacktrace
    print("Error fetching stream data for collection '$collection': $e");
    print("Stacktrace: $stacktrace");
    return const Stream.empty(); // Fallback for errors
  }
}

  Stream<QuerySnapshot> getStreamDataByField({
    required String collection,
    required String field,
    required dynamic value,
    bool? descending,
    String? orderBy,
  }) {
    try {
      // Create the query
      var query = _db.collection(collection).where(field, isEqualTo: value);

      // Add optional ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      // Return the stream of snapshots
      return query.snapshots();
    } catch (e) {
      print("Error fetching stream data by field: $e");
      return const Stream.empty(); // Fallback for errors
    }
  }

  Future<List<Map<String, dynamic>>> queryData({
    required String collection,
    required String field,
    required String query,
  }) async {
    final snapshot = await _db
        .collection(collection)
        .where(field, isGreaterThanOrEqualTo: query)
        .where(field, isLessThan: query + '\uf8ff') // For prefix matching
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
  Stream<QuerySnapshot> getStreamDataByTwoField({
    required String collection,
    required String field,
    required dynamic value,
    required String field2,
    required dynamic value2,
    bool? descending,
    String? orderBy,
  }) {
    try {
      // Create the query
      var query = _db
          .collection(collection)
          .where(field, isEqualTo: value)
          .where(field2, isEqualTo: value2);

      // Add optional ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      // Return the stream of snapshots
      return query.snapshots();
    } catch (e) {
      print("Error fetching stream data by field: $e");
      return const Stream.empty(); // Fallback for errors
    }
  }

  // Select Data (Get All Sub Collection Data)
  Stream<QuerySnapshot> getSubCollectionMessagesStreamData({
    required String collection,
    required String subCollection,
    required String docId,
    bool? descending,
  }) {
    try {
      return _db
          .collection(collection)
          .doc(docId)
          .collection(subCollection)
          .orderBy("created_at", descending: descending ?? true)
          .snapshots();
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error scenario appropriately
      // You could return an empty Stream or rethrow the error
      return const Stream.empty(); // Empty stream as a fallback
    }
  }

  Stream<DocumentSnapshot> getConversationStreamData({
    required String collection,
    required String docId,
  }) {
    try {
      return _db.collection(collection).doc(docId).snapshots();
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error scenario appropriately
      // You could return an empty Stream or rethrow the error
      return Stream.empty(); // Empty stream as a fallback
    }
  }

  Future<Map<String, dynamic>?> getSubCollectionDataById({
    required String collection,
    required String subCollection,
    required String docId,
    required String subDocId,
  }) async {
    try {
      final docSnapshot = await _db
          .collection(collection)
          .doc(docId)
          .collection(subCollection)
          .doc(subDocId)
          .get();
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

  Future<void> incrementFieldInSubCollection(
      String collection,
      String documentId,
      String subCollection,
      String subDocumentId,
      int increaseNum,
      String field) async {
    try {
      // Update the document by incrementing the numeric field
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .collection(subCollection)
          .doc(subDocumentId)
          .update({
        field: FieldValue.increment(increaseNum),
      });

      print("Field incremented successfully!");
    } catch (e) {
      print("Error incrementing field: $e");
    }
  }

    Future<void> incrementField(
      String collection,
      String documentId,
      int increaseNum,
      String field) async {
    try {
      // Update the document by incrementing the numeric field
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .update({
        field: FieldValue.increment(increaseNum),
      });

      print("Field incremented successfully!");
    } catch (e) {
      print("Error incrementing field: $e");
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

// Select Data (Get by two Field Values)
  Future<List<Map<String, dynamic>>> getDataByTwoFields(String collection,
      String field1, dynamic value1, String field2, dynamic value2) async {
    try {
      final querySnapshot = await _db
          .collection(collection)
          .where(field1, isEqualTo: value1)
          .where(field2, isEqualTo: value2)
          .get();

      List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        dataList.add(doc.data() as Map<String, dynamic>);
      }
      return dataList;
    } catch (e) {
      print("Error fetching data by fields: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?>? getSubCollectionData(
    String collection,
    String documentId, // Document ID of the parent document
    String subCollection, // Name of the subcollection
  ) async {
    try {
      // Access the parent document first
      final parentDocRef = _db.collection(collection).doc(documentId);

      // Get the subcollection from the parent document
      final querySnapshot = await parentDocRef.collection(subCollection).get();

      List<Map<String, dynamic>> dataList = [];
      for (var doc in querySnapshot.docs) {
        dataList.add(doc.data() as Map<String, dynamic>);
      }

      return dataList;
    } catch (e) {
      print("Error fetching subcollection data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSubCollectionOneDataByFields(
    String parentCollection,
    String parentDocId,
    String subCollection,
    String field,
    dynamic value,
  ) async {
    try {
      final querySnapshot = await _db
          .collection(parentCollection) // Parent collection
          .doc(parentDocId) // Parent document ID
          .collection(subCollection) // Subcollection
          .where(field, isEqualTo: value) // Filter by field
          .get();

      // Check if any documents exist in the query
      if (querySnapshot.docs.isNotEmpty) {
        // Return the first matching document's data
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("No matching documents found in the subcollection.");
        return null;
      }
    } catch (e) {
      print("Error fetching data from subcollection by field: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSubCollectionOneDataByTwoFields(
    String parentCollection,
    String parentDocId,
    String subCollection,
    String field1,
    dynamic value1,
    String field2,
    dynamic value2,
  ) async {
    try {
      final querySnapshot = await _db
          .collection(parentCollection) // Parent collection
          .doc(parentDocId) // Parent document ID
          .collection(subCollection) // Subcollection
          .where(field2, isEqualTo: value2) // Filter by field
          .where(field1, isEqualTo: value1) // Filter by field
          .get();

      // Check if any documents exist in the query
      if (querySnapshot.docs.isNotEmpty) {
        // Return the first matching document's data
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("No matching documents found in the subcollection.");
        return null;
      }
    } catch (e) {
      print("Error fetching data from subcollection by field: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSubCollectionOneDataByThreeFields(
    String parentCollection,
    String parentDocId,
    String subCollection,
    String field1,
    dynamic value1,
    String field2,
    dynamic value2,
    String field3, // New field
    dynamic value3, // New value
  ) async {
    try {
      final querySnapshot = await _db
          .collection(parentCollection) // Parent collection
          .doc(parentDocId) // Parent document ID
          .collection(subCollection) // Subcollection
          .where(field1, isEqualTo: value1) // Filter by first field
          .where(field2, isEqualTo: value2) // Filter by second field
          .where(field3, isEqualTo: value3) // Filter by third field
          .get();

      // Check if any documents exist in the query
      if (querySnapshot.docs.isNotEmpty) {
        // Return the first matching document's data
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("No matching documents found in the subcollection.");
        return null;
      }
    } catch (e) {
      print("Error fetching data from subcollection by fields: $e");
      return null;
    }
  }

// Stream Data (Get Conversations Stream)
  Stream<List<Map<String, dynamic>>> getConversationsStream(
      String currentUserId) {
    try {
      // Listen to changes in the "Conversations" collection
      return _db
          .collection('Conversations')
          .where('participants', arrayContains: currentUserId)
          .orderBy('updated_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    } catch (e) {
      print("Error fetching conversations stream: $e");
      return Stream.value([]);
    }
  }

  Future<Map<String, dynamic>?> getFilteredDataDirectly(
      String collection, String field, List<String> targetValues) async {
    try {
      if (targetValues.length != 2) {
        throw ArgumentError('Target values must contain exactly two items.');
      }

      // Fetch documents with `array-contains` for the first value
      final querySnapshot = await _db
          .collection(collection)
          .where(field,
              arrayContains: targetValues[0]) // Only one array-contains
          .get();

      // List<Map<String, dynamic>> dataList = [];
      // for (var doc in querySnapshot.docs) {
      //   dataList.add(doc.data() as Map<String, dynamic>);
      // }

      // List<ConversationModel> conversationList =
      //     dataList.map((item) => ConversationModel.fromMap(item)).toList();

      // Filter locally to match both values and ensure list length is 2
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final listField = List<String>.from(doc['participants'] ?? []);
        print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&' +
            listField.toString());

        if (listField != null &&
            listField.length == 2 &&
            listField.toSet().containsAll(targetValues)) {
          return data; // Return the first valid match
        }
      }

      // If no valid document is found, return null
      return null;
    } catch (e) {
      print("Error fetching filtered data: $e");
      return null;
    }
  }

  Future<bool> insertUserWithUniqueUsername(String username) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Check if username already exists in Firestore
    final QuerySnapshot result = await firestore
        .collection('User')
        .where('username',
            isEqualTo: username) // 'username' is the field in your Firestore
        .get();

    if (result.docs.isNotEmpty) {
      return false; // Username already taken, return false
    } else {
      return true; // Username not taken
    }
  }

  Future<bool> isUsernameCorrectForUID(String username, String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot querySnapshot = await firestore
        .collection('User')
        .where('username', isEqualTo: username)
        .get();

    // Check if any user with the same username exists, except the current user
    for (var doc in querySnapshot.docs) {
      if (doc.id != uid) {
        // A different user has the same username
        return false;
      }
    }

    //Username is unique if no other user matches
    return true;
  }

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  Future<void> searchUser(String username) async {
    final firestore = FirebaseFirestore.instance;
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    final result = await firestore
        .collection('User')
        .where('username', isEqualTo: username)
        .get();

    if (result.docs.isNotEmpty) {
      final filteredResults = result.docs.where((doc) {
        return doc.id != currentUserUid; // Exclude the logged-in user
      }).toList();

      if (filteredResults.isNotEmpty) {
        var userData = result.docs.first.data() as Map<String, dynamic>;
        String userId = result.docs.first.id;

        _userModel = UserModel.fromMap(userData, userId);
      } else {
        _userModel = null;
      }
    } else {
      _userModel = null;
    }
  }
}
