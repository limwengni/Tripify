import 'package:firebase_storage/firebase_storage.dart';

class UserModel {
  final String? username;
  final String? ssm;
  final String? bio;
  final String? profilePic;
  final DateTime? birthdate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String uid;

  UserModel({
    this.username,
    this.ssm,
    this.bio,
    this.profilePic,
    this.birthdate,
    this.createdAt,
    this.updatedAt,
    required this.uid,
  });

  Future<String> fetchProfileImageUrl() async {
    if (profilePic != null && profilePic!.isNotEmpty) {
      try{
        final storageRef = FirebaseStorage.instance.ref('${uid}/pfp/$profilePic');

        final url = await storageRef.getDownloadURL();
        return url;
      } catch (e) {
        print('Error fetching profile image URL: $e');
        return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
      }
    }
    return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
  }
}
