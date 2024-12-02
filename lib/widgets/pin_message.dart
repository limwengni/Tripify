import 'package:flutter/material.dart';

class PinMessage extends StatelessWidget {
  final String message; // Declare a String variable to store the message

  // Constructor to accept a string value
  PinMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            offset: Offset(0, 2), // Horizontal and vertical offset of the shadow
            blurRadius: 4, // Softness of the shadow
            spreadRadius: 1, // How much the shadow spreads
          ),
        ],
      ),
      child: Row(
        children: [
          // Text that will show up to 2 lines with ellipsis if it overflows
          Expanded(
            child: Text(
              message, // Use the passed string here
              maxLines: 2, // Show up to 2 lines
              overflow: TextOverflow.ellipsis, // Add ellipsis if the text overflows
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Pin icon that stays at the right
          Icon(Icons.push_pin),

          // DropdownButton at the end to show full message
          IconButton(
            icon: Icon(Icons.arrow_drop_down),
            onPressed: () {
              // Action when the button is pressed (e.g., show full message)
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Pin Message'),
                    content: Text(message), // Show the full message
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
