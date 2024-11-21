import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final String? latestMessage;
  final String? messagePinnedId;
  final DateTime? latestMessageSendDateTime;
  final bool isGroup;
  final String? host;
  final bool? isDeleted;
  final String? senderId;
  final Map<String, int>? unreadMessage;  // Changed to Map<String, int>
  final String? conversationPic;
  final String? groupName;
  final DateTime? updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    this.latestMessage,
    this.messagePinnedId,
    this.latestMessageSendDateTime,
    required this.isGroup,
    this.host,
    this.isDeleted,
    this.conversationPic,
    this.senderId,
    this.unreadMessage,  // Changed to Map<String, int>?
    this.groupName,
    required this.updatedAt,
  });

  // Convert the ConversationModel instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'latest_message': latestMessage,
      'message_pinned_id': messagePinnedId,
      'latest_message_send_date_time': latestMessageSendDateTime,
      'is_group': isGroup,
      'host': host,
      'is_deleted': isDeleted,
      'conversation_pic': conversationPic,
      'sender_id': senderId,
      'unread_message': unreadMessage,  // Storing the unread_message map
      'group_name': groupName,
      'updated_at': updatedAt,
    };
  }

  // Create a ConversationModel instance from a Map
  factory ConversationModel.fromMap(Map<String, dynamic> data) {
    return ConversationModel(
      id: data['id'],
      participants: List<String>.from(data['participants']),
      latestMessage: data['latest_message'],
      messagePinnedId: data['message_pinned_id'],
      latestMessageSendDateTime: (data['latest_message_send_date_time'] is Timestamp)
          ? (data['latest_message_send_date_time'] as Timestamp).toDate()
          : DateTime.parse(data['latest_message_send_date_time']),
      isGroup: data['is_group'],
      host: data['host'],
      isDeleted: data['is_deleted'],
      conversationPic: data['conversation_pic'],
      senderId: data['sender_id'],
      // Handle unread_message as a Map<String, int>
      unreadMessage: (data['unread_message'] != null)
          ? Map<String, int>.from(data['unread_message'])
          : null,
      groupName: data['group_name'],
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.parse(data['updated_at']),
    );
  }
}
