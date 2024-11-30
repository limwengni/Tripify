import 'package:cloud_firestore/cloud_firestore.dart';

class Hashtag {
  String? id;
  final String name;
  int usageCount;

  Hashtag({this.id, required this.name, required this.usageCount});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'usage_count': usageCount,
    };
  }
  
  factory Hashtag.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Hashtag(
      id: doc.id,
      name: data['name'],
      usageCount: data['usage_count'] ?? 0,
    );
  }
}
