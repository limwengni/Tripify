class Media {
  final String uid; // The unique identifier for the post
  final Map<int, String> filenames; // Map image index to filename

  Media({
    required this.uid,
    required this.filenames,
  });

  // Factory method to create Media from Map
  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      uid: map['uid'],
      filenames: Map<int, String>.from(map['filenames'] ?? {}),
    );
  }
  // Similarly, add a method to convert to JSON if needed
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'filenames': filenames,
    };
  }
}
