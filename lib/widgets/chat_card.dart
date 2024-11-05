import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({super.key});

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(children: [
              Text(
                'username',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Text('message...'),
            ]),
            const Spacer(),
            Column(
              children: [
                const Row(
                  children: [
                    Text('12:01 PM'),
                    Icon(Icons.push_pin,size: 15,),
                  ],
                ),
                Container(
            width: 30, // Width of the circle
            height: 30, // Height of the circle
            decoration: const BoxDecoration(
              color: Colors.blue, // Circle background color
              shape: BoxShape.circle, // Make the shape circular
            ),
            alignment: Alignment.center, // Center the text within the circle
            child: const Text(
              '9+',
              style: TextStyle(
                color: Colors.white, // Text color
               // Text size
                fontWeight: FontWeight.bold, // Text weight
              ),
            ),
          ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
