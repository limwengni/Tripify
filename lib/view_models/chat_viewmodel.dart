import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatModel _chatModel = ChatModel();
  List<Map<String, String>> messages = [];
  List<Widget> itineraryButtons = [];
  bool isTyping = false;
  bool showPrompts = true;

  ChatViewModel() {
    messages.add({
      'text':
          "Hey there! Travis here, your travel assistant. What can I help you plan today?",
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
        'text':
            "Hmm, it seems there was a network error. Please try again later.",
        'sender': 'ai'
      });
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  void addItineraryButton(Widget button) {
    itineraryButtons.add(button);
    notifyListeners();
  }

  Future<void> sendItineraryToApi(
      Map<String, dynamic> selectedItineraryData, String userId) async {
    isTyping = true;
    notifyListeners();

    try {
      final requestData =
          "Here is the itinerary data: ${selectedItineraryData.toString()}";
      print("Sending itinerary data: $requestData");

      final itineraryResponse =
          await _chatModel.sendMessageToApi(requestData, userId);

      print("API Response: $itineraryResponse");

      // Handle response and update UI as needed
      if (itineraryResponse != null) {
        messages.add({'text': itineraryResponse, 'sender': 'ai'});
        notifyListeners();
      } else {
        messages.add({
          'text':
              "No itinerary data received from the API. Please try again later.",
          'sender': 'ai',
        });
      }
    } catch (e) {
      // Handle error
      messages.add({
        'text':
            "There was an error while uploading the itinerary. Please try again later.",
        'sender': 'ai',
      });
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }
}
