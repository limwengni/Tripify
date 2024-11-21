import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FirebaseStorageService {
  // Private constructor to prevent instantiation
  FirebaseStorageService._();

  // Static instance variable to hold the singleton instance
  static final FirebaseStorageService _instance = FirebaseStorageService._();

  // Factory method to get the singleton instance
  factory FirebaseStorageService() {
    return _instance;
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> saveFileToFirestore(
      {required FilePickerResult file, required String storagePath}) async {
    String fileName = file.files.single.name;
    final filePath = file.files.single.path!;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = '${timestamp}_$fileName';
    final fileRef = _storage.ref().child('$storagePath/$newFileName');

    try {
      // Upload the file to Firebase Storage
      await fileRef.putFile(File(filePath));

      // Get the download URL of the uploaded file
      String downloadUrl = await fileRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }

  Future<String?> saveImageVideoToFirestore(
      {required File file, required String storagePath}) async {
    String fileName = file.uri.pathSegments.last;

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = '${timestamp}_$fileName';

    final fileRef = _storage.ref().child('$storagePath/$newFileName');

    try {
      // Upload the file to Firebase Storage
      await fileRef.putFile(file);

      // Get the download URL of the uploaded file
      String downloadUrl = await fileRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }

  Future<String?> saveToFirestore(
      {required File file, required String storagePath}) async {
    String fileName = file.uri.pathSegments.last;

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = '${timestamp}_$fileName';

    final fileRef = _storage.ref().child('$storagePath/$newFileName');

    try {
      // Upload the file to Firebase Storage
      await fileRef.putFile(file);

      // Get the download URL of the uploaded file
      String downloadUrl = await fileRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }
}
