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
  String? conversationPic;
  String? groupName;
  final DateTime? updatedAt;
  String? latestMessageType;

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
    this.latestMessageType,
  });

  // Convert the ConversationModel instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'latest_message': latestMessage??'',
      'message_pinned_id': messagePinnedId??'',
      'latest_message_send_date_time': latestMessageSendDateTime,
      'is_group': isGroup,
      'host': host??'',
      'is_deleted': isDeleted??false,
      'conversation_pic': conversationPic??'',
      'sender_id': senderId??'',
      'unread_message': unreadMessage??'',
      'group_name': groupName??'',
      'updated_at': updatedAt??'',
      'latest_message_type': latestMessageType??'',
    };
  }

  // Create a ConversationModel instance from a Map
factory ConversationModel.fromMap(Map<String, dynamic> data) {
  return ConversationModel(
    id: data['id'] ?? '',  // Default empty string if null
    participants: List<String>.from(data['participants'] ?? []),  // Default empty list if null
    latestMessage: data['latest_message'] ?? '',  // Default empty string if null
    messagePinnedId: data['message_pinned_id'] ?? '',  // Default empty string if null
    latestMessageSendDateTime:
        (data['latest_message_send_date_time'] is Timestamp)
            ? (data['latest_message_send_date_time'] as Timestamp).toDate()
            : (data['latest_message_send_date_time'] != null
                ? DateTime.parse(data['latest_message_send_date_time'])
                : null), // Handle null case for DateTime
    isGroup: data['is_group'] ?? false,  // Default false if null
    host: data['host'] ?? '',  // Default empty string if null
    isDeleted: data['is_deleted'] ?? false,  // Default false if null
    conversationPic: data['conversation_pic'] ?? '',  // Default empty string if null
    senderId: data['sender_id'] ?? '',  // Default empty string if null
    unreadMessage: (data['unread_message'] != null)
        ? Map<String, int>.from(data['unread_message'])
        : null,  // Handle null case for unread messages
    groupName: data['group_name'] ?? '',  // Default empty string if null
    updatedAt: (data['updated_at'] is Timestamp)
        ? (data['updated_at'] as Timestamp).toDate()
        : (data['updated_at'] != null
            ? DateTime.parse(data['updated_at'])
            : null),  // Handle null case for DateTime
    latestMessageType: data['latest_message_type'] ?? '',  // Default empty string if null
  );
}

  // Update the group name
  void updateGroupName(String newGroupName) {
    groupName = newGroupName;
  }
  void updateGroupPic(String newGroupPic) {
    conversationPic = newGroupPic;
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
