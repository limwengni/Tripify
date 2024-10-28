import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';

class TravelAssistantPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Travis - Travel Assistant'),
        ),
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
                  hintStyle: TextStyle(fontSize: 14.0),
                  border: InputBorder.none,
                ),
                enabled: !viewModel.isTyping,
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
                    icon: const Icon(Icons.send),
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
      viewModel.sendMessage(message, 1);
      _controller.clear();
      _scrollToBottom();
    }
  }

  Widget _buildChatBubble(BuildContext context, String message, String sender) {
    bool isUser = sender == 'user';

    if (isUser) {
      // User response with bubble
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 160, 118, 249),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: RichText(
              text: TextSpan(
                children: parseMarkdown(message, true),
              ),
            ),
          ),
        ),
      );
    } else {
      // AI response with circle avatar
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns items at the start (top)
            children: [
              CircleAvatar(
                radius: 15.0, // Adjust the size as needed
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(
                    '../assets/images/travis.png'), // Correct path to load the image
              ),
              SizedBox(width: 8.0), // Space between avatar and message
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: parseMarkdown(message, false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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

    // Add the remaining text after the last match
    if (lastIndex < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastIndex),
        style: TextStyle(color: isUser ? Colors.white : Colors.black),
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
