import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatModel _chatModel = ChatModel();
  List<Map<String, String>> messages = [];
  bool isTyping = false;
  bool showPrompts = true;

  ChatViewModel() {
    messages.add({
      'text': "Hey there! Travis here, your travel assistant. What can I help you plan today?",
      'sender': 'ai'
    });
  }

  Future<void> sendMessage(String message, String userId) async {
    messages.add({'text': message, 'sender': 'user'});
    isTyping = true;
    notifyListeners();

    try {
      final botResponse = await _chatModel.sendMessageToApi(message, userId);
      messages.add({'text': botResponse, 'sender': 'ai'});
    } catch (e) {
      messages.add({
        'text': "Hmm, it seems there was a network error. Please try again later.",
        'sender': 'ai'
      });
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }
}
