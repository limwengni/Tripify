import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/message_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class ConversationViewModel {
  FirestoreService firestoreService = FirestoreService();

  Future<void> sendMessage({ required String senderID, required String content,
      required ContentType contentType, required String conversationId, String? thumbnailDownloadUrl}) async {
    //get current user info
    MessageModel newMessage = MessageModel(
      id: "",
      senderId: senderID,
      contentType: contentType,
      content: content,
      isDeleted: false,
      createdAt: DateTime.now(),
      conversationId: conversationId,
      thumbnailDownloadUrl: thumbnailDownloadUrl,
    );

    await firestoreService.insertSubCollectionDataWithAutoID(
        "Conversations", "Messages", conversationId, newMessage.toMap());

  }

  Stream<QuerySnapshot> getMessages({required String conversationId}) {
    return firestoreService.getSubCollectionMessagesStreamData(
        collection: "Conversations",
        subCollection: "Messages",
        docId: conversationId,
        descending: false);
  }
}
