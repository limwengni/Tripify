import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/message_model.dart';
import 'package:tripify/models/poll_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class ConversationViewModel {
  FirestoreService firestoreService = FirestoreService();

  Future<void> sendMessage(
      {required String senderID,
      required String content,
      required ContentType contentType,
      required ConversationModel conversation,
      String? thumbnailDownloadUrl,
      String? fileName}) async {
    DateTime sendTime = DateTime.now();
    //get current user info
    MessageModel newMessage = MessageModel(
      id: "",
      senderId: senderID,
      contentType: contentType,
      content: content,
      isDeleted: false,
      createdAt: sendTime,
      thumbnailDownloadUrl: thumbnailDownloadUrl,
      fileName: fileName,
      conversationId: conversation.id,
    );

    await firestoreService.insertSubCollectionDataWithAutoID(
        "Conversations", "Messages", conversation.id, newMessage.toMap());
    String contentTypeAsString = contentType.toString().split('.').last;

    await firestoreService.updateField(
        'Conversations', conversation.id, 'latest_message', newMessage.content);
    await firestoreService.updateField('Conversations', conversation.id,
        'latest_message_send_date_time', sendTime);
    await firestoreService.updateField(
        'Conversations', conversation.id, 'updated_at', sendTime);
    await firestoreService.updateField('Conversations', conversation.id,
        'latest_message_type', contentTypeAsString);

    conversation.setLatestDateTime(sendTime);

    for (String key in conversation.unreadMessage!.keys) {
      conversation.unreadMessage![key] = conversation.unreadMessage![key]! + 1;
    }
    await firestoreService.updateField('Conversations', conversation.id,
        'unread_message', conversation.unreadMessage);
  }

  Future<void> sendPollMessage(
      {required PollModel poll,
      required ConversationModel conversation}) async {
    String pollId =
        await firestoreService.insertSubCollectionDataWithAutoIDReturnValue(
            "Conversations", "Poll", conversation.id, poll.toMap());
    sendMessage(
        senderID: poll.createdBy,
        content: pollId,
        contentType: ContentType.poll,
        conversation: conversation);
  }

  Stream<QuerySnapshot> getMessages({required String conversationId}) {
    return firestoreService.getSubCollectionMessagesStreamData(
        collection: "Conversations",
        subCollection: "Messages",
        docId: conversationId,
        descending: true);
  }

  Stream<DocumentSnapshot> getConversationStream(
      {required String conversationId}) {
    return firestoreService.getConversationStreamData(
        collection: 'Conversations', docId: conversationId);
  }
}
