import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

enum ContentType {
  text,
  file,
  pic,
  video,
  poll,
}

class MessageModel {
  final String id;
  final String senderId;
  final ContentType contentType;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;
  final String conversationId;
  final String? thumbnailDownloadUrl;
  final String? fileName;

  // Constructor
  MessageModel( {
    required this.id,
    required this.senderId,
    required this.contentType,
    required this.content,
    required this.isDeleted,
    required this.createdAt,
    required this.conversationId,
    this.thumbnailDownloadUrl,
    this.fileName,
  });

  // Convert Message to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'content_type': contentType
          .toString()
          .split('.')
          .last, // Get the name of the enum value
      'content': content,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'coversation_id': conversationId,
      'thumbnail_download_url': thumbnailDownloadUrl,
      'file_name': fileName,
    };
  }

  // Convert Map to Message
factory MessageModel.fromMap(Map<String, dynamic> data) {
  return MessageModel(
    id: data['id'] ?? '',  // Default to an empty string if 'id' is null
    senderId: data['sender_id'] ?? '',  // Default to an empty string if 'sender_id' is null
    contentType: ContentType.values.firstWhere(
      (e) => e.toString().split('.').last == (data['content_type'] ?? ''),
      orElse: () => ContentType.text,  // Default to text if 'content_type' is null or not found
    ),
    content: data['content'] ?? '',  // Default to an empty string if 'content' is null
    isDeleted: data['is_deleted'] ?? false,  // Default to false if 'is_deleted' is null
    createdAt: (data['create_at'] is Timestamp)
        ? (data['create_at'] as Timestamp).toDate()
        : (data['create_at'] != null
            ? DateTime.parse(data['create_at'] as String)
            : DateTime.now()),  // Default to current time if 'create_at' is null
    conversationId: data['conversation_id'] ?? '',  // Default to an empty string if 'conversation_id' is null
    thumbnailDownloadUrl: data['thumbnail_download_url'] ?? '',  // Default to an empty string if 'thumbnail_download_url' is null
    fileName: data['file_name'] ?? '',  // Default to an empty string if 'file_name' is null
  );
}

}
