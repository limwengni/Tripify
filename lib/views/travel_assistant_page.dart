import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/view_models/chat_viewmodel.dart';

class TravelAssistantPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        body: Consumer<ChatViewModel>(
          builder: (context, viewModel, child) {
            // Automatically scroll to the bottom whenever messages are updated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.messages.isNotEmpty) {
                _scrollToBottom();
              }
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(
                        context,
                        viewModel.messages[index]['text']!,
                        viewModel.messages[index]['sender']!,
                      );
                    },
                  ),
                ),
                _buildInputField(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, ChatViewModel viewModel) {
    return Padding(
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
                  hintText: 'Ask anything...',
                  hintStyle:
                      TextStyle(fontSize: 14.0, color: Color(0xFF3B3B3B)),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                cursorColor: Color(0xFF3B3B3B),
                enabled: !viewModel.isTyping,
                style: TextStyle(
                  color: Color(0xFF3B3B3B), // Light mode text color
                ),
                onSubmitted: (value) {
                  if (!viewModel.isTyping) {
                    _sendMessage(context, viewModel, value);
                  }
                },
              ),
            ),
            viewModel.isTyping
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: CircularProgressIndicator(strokeWidth: 3.0),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF3B3B3B)),
                    onPressed: () =>
                        _sendMessage(context, viewModel, _controller.text),
                  ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(
      BuildContext context, ChatViewModel viewModel, String message) {
    if (message.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      viewModel.sendMessage(message, userId);
      _controller.clear();
      _scrollToBottom();
    }
  }

  Widget _buildChatBubble(BuildContext context, String message, String sender) {
    bool isUser = sender == 'user';

    if (isUser) {
      // User response with bubble
      return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 160, 118, 249),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: RichText(
                  text: TextSpan(
                    children: parseMarkdown(message, true, context),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ));
    } else {
      // AI response with circle avatar
      return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Aligns items at the start (top)
                children: [
                  CircleAvatar(
                    radius: 15.0, // Adjust the size as needed
                    backgroundColor: Colors.grey[300],
                    backgroundImage: AssetImage(
                        './assets/images/travis.png'), // Correct path to load the image
                  ),
                  SizedBox(width: 8.0), // Space between avatar and message
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: parseMarkdown(message, false, context),
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
  }

  List<InlineSpan> parseMarkdown(
      String message, bool isUser, BuildContext context) {
    List<InlineSpan> spans = [];
    RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (Match match in regex.allMatches(message)) {
      spans.add(TextSpan(
        text: message.substring(lastIndex, match.start),
        style: TextStyle(
            color: isUser
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color),
      ));

      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUser
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color),
      ));

      lastIndex = match.end;
    }

    // Add the remaining text after the last match
    if (lastIndex < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastIndex),
        style: TextStyle(
            color: isUser
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color),
      ));
    }

    return spans;
  }

  void _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await Future.delayed(
          Duration(milliseconds: 100)); // Allows for smoother async transitions
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
