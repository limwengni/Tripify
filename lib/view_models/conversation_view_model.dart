import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/message_model.dart';
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
      createdAt:sendTime,
      thumbnailDownloadUrl: thumbnailDownloadUrl,
      fileName: fileName,
      conversationId: conversation.id,
    );

    await firestoreService.insertSubCollectionDataWithAutoID(
        "Conversations", "Messages", conversation.id, newMessage.toMap());

      conversation.setLatestMessage(newMessage.content);
      conversation.setLatestDateTime(sendTime);
      await firestoreService.updateData(
        "Conversations", conversation.id, conversation.toMap());
  }

  Stream<QuerySnapshot> getMessages({required String conversationId}) {
    return firestoreService.getSubCollectionMessagesStreamData(
        collection: "Conversations",
        subCollection: "Messages",
        docId: conversationId,
        descending: false);
  }
}
