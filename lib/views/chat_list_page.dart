import 'package:flutter/material.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/widgets/chat_card.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final List<String> _allItems = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew'
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final SearchController controller = SearchController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                searchController: controller,
                viewHintText: 'Search...',
                viewTrailing: [
                  IconButton(
                    onPressed: () {
                      controller.closeView(controller.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    leading: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        controller.openView();
                      },
                    ),
                    hintText: 'Search...',
                    onTap: () => controller.openView(),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final query = controller.value.text;
                  final suggestions = _allItems
                      .where((item) =>
                          item.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  return suggestions.isNotEmpty
                      ? suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              controller.closeView(
                                  suggestion); // Close view and set the query
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('You selected $suggestion')),
                              );
                            },
                          );
                        }).toList()
                      : [const ListTile(title: Text('No results found'))];
                },
              ),
            ),
            ChatCard(),
          ],
        ));
  }
}
