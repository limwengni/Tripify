import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  List<String> participants; // Made mutable to allow updates
  String? latestMessage;
  final String? messagePinnedId;
  DateTime? latestMessageSendDateTime;
  final bool isGroup;
  final String? host;
  final bool? isDeleted;
  final String? senderId;
  final Map<String, int>? unreadMessage;
  final String? conversationPic;
  String? groupName;
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
    this.unreadMessage,
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
      'unread_message': unreadMessage,
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
      latestMessageSendDateTime:
          (data['latest_message_send_date_time'] is Timestamp)
              ? (data['latest_message_send_date_time'] as Timestamp).toDate()
              : DateTime.parse(data['latest_message_send_date_time']),
      isGroup: data['is_group'],
      host: data['host'],
      isDeleted: data['is_deleted'],
      conversationPic: data['conversation_pic'],
      senderId: data['sender_id'],
      unreadMessage: (data['unread_message'] != null)
          ? Map<String, int>.from(data['unread_message'])
          : null,
      groupName: data['group_name'],
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : DateTime.parse(data['updated_at']),
    );
  }

  // Update the group name
  void updateGroupName(String newGroupName) {
    groupName = newGroupName;
  }

  // Add a participant
  void addParticipant(String userId) {
    if (!participants.contains(userId)) {
      participants.add(userId);
    }
  }

  // Remove a participant
  void removeParticipant(String userId) {
    participants.remove(userId);
  }

  // Replace all participants
  void setParticipants(List<String> newParticipants) {
    participants = newParticipants;
  }

  // Check if a user is a participant
  bool isParticipant(String userId) {
    return participants.contains(userId);
  }

  void setLatestMessage(String latestMessage) {
    this.latestMessage = latestMessage;
  }

  void setLatestDateTime(DateTime latestDateTime){
   latestMessageSendDateTime = latestDateTime;
  }
  
  void clearUnreadMessage(String userId) {
  // Set the unread message count for the user
  unreadMessage![userId] = 0;
}
}
