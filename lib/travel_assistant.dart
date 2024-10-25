import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shimmer/shimmer.dart';

class TravelAssistant extends StatefulWidget {
  const TravelAssistant({super.key});

  @override
  _TravelAssistantState createState() => _TravelAssistantState();
}

class _TravelAssistantState extends State<TravelAssistant> {
  List<Map<String, String>> messages = [];
  late Future<List<String>> futurePrompts;
  final TextEditingController _controller = TextEditingController();
  bool isTyping = false;
  bool showPrompts = true;
  late Timer _typingTimer;
  int dotCount = 1;

  @override
  void initState() {
    super.initState();

    messages = [
      {
        'text':
            "Hey there! Travis here, your travel assistant. What can I help you plan today?",
        'sender': 'ai'
      }
    ];

    // Uncomment the next line to fetch prompts if that feature is needed
    // futurePrompts = fetchPrompts();
  }

  // // Function to fetch generated prompts from the backend
  // Future<List<String>> fetchPrompts() async {
  //   final response =
  //       await http.get(Uri.parse('http://127.0.0.1:5000/api/prompts'));
  //   if (response.statusCode == 200) {
  //     return List<String>.from(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load prompts');
  //   }
  // }

  // Function to send message to my API
  Future<String> sendMessageToApi(String message, int userId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/message'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to load response');
    }
  }

  List<InlineSpan> parseMarkdown(String message, bool isUser) {
    List<InlineSpan> spans = [];
    RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (Match match in regex.allMatches(message)) {
      spans.add(TextSpan(
        text: message.substring(lastIndex, match.start),
        style: TextStyle(color: isUser ? Colors.white : Colors.black),
      ));

      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUser ? Colors.white : Colors.black),
      ));

      lastIndex = match.end;
    }

    spans.add(TextSpan(
      text: message.substring(lastIndex),
      style: TextStyle(color: isUser ? Colors.white : Colors.black),
    ));

    return spans;
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        isTyping = true;
        messages.add({'text': message, 'sender': 'user'});
        showPrompts = false;
      });
      _controller.clear();
      _getBotResponse(message);
    }
  }

  void _getBotResponse(String userMessage) async {
    setState(() {
      isTyping = true;
      messages.add({'text': '', 'sender': 'ai', 'isTyping': 'true'});
      dotCount = 1;
      _startTypingIndicator();
    });

    try {
      String botResponse =
          await sendMessageToApi(userMessage, 1); // Default user ID set to 1
      _stopTypingIndicator();

      setState(() {
        messages.removeWhere(
            (msg) => msg['isTyping'] == 'true' && msg['sender'] == 'ai');
        messages.add({'text': botResponse, 'sender': 'ai'});
        isTyping = false;
      });
    } catch (error) {
      _stopTypingIndicator();

      setState(() {
        messages.removeWhere(
            (msg) => msg['isTyping'] == 'true' && msg['sender'] == 'ai');
        messages.add({
          'text':
              "Hmm, it seems there was a network error. Please try again later.",
          'sender': 'ai'
        });
        isTyping = false;
      });
    }
  }

  void _startTypingIndicator() {
    _typingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1;
      });
    });
  }

  void _stopTypingIndicator() {
    _typingTimer.cancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (isTyping) {
      _stopTypingIndicator();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travis - Travel Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(
                  messages[index]['text']!,
                  messages[index]['sender']!,
                );
              },
            ),
          ),
          // if (showPrompts)
          //   FutureBuilder<List<String>>(
          //     future: futurePrompts,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return CircularProgressIndicator();
          //       } else if (snapshot.hasError) {
          //         return Text('Failed to fetch prompts');
          //       } else {
          //         return Column(
          //           children: snapshot.data!.map((prompt) {
          //             return ListTile(
          //               title: Text(prompt),
          //               onTap: () {
          //                 _sendMessage(prompt);
          //                 setState(() {
          //                   showPrompts = false;
          //                 });
          //               },
          //             );
          //           }).toList(),
          //         );
          //       }
          //     },
          //   ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: ' Ask anything...',
                        hintStyle: TextStyle(fontSize: 14.0),
                        border: InputBorder.none,
                      ),
                      enabled: !isTyping,
                      onSubmitted: (value) {
                        if (!isTyping) {
                          _sendMessage(value);
                        }
                      },
                    ),
                  ),
                  isTyping
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String message, String sender) {
    bool isUser = sender == 'user';

    if (sender == 'ai' && message.isEmpty) {
      return _buildTypingText();
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUser
                ? Color.fromARGB(255, 160, 118, 249)
                : Color.fromARGB(255, 226, 226, 226), // User: purple, AI: grey
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: RichText(
            text: TextSpan(
              children: parseMarkdown(message, isUser),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Text(
        'Travis is typing' + '.' * dotCount,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
