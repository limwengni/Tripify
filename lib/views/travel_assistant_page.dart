import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/view_models/chat_viewmodel.dart';
import 'package:tripify/view_models/itinerary_provider.dart';

class TravelAssistantPage extends StatefulWidget {
  @override
  _TravelAssistantPageState createState() => _TravelAssistantPageState();
}

class _TravelAssistantPageState extends State<TravelAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Widget> itineraryButtons = [];
  bool itineraryButtonAdded = false;

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

                if (!itineraryButtonAdded && viewModel.messages.length == 1) {
                  setState(() {
                    itineraryButtonAdded = true;
                  });
                }
              }
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      var message = viewModel.messages[index];
                      print(
                          "Messages list after adding AI response: ${message}");
                      return _buildChatBubble(
                        context,
                        viewModel.messages[index]['text']!,
                        viewModel.messages[index]['sender']!,
                      );
                    },
                  ),
                ),
                if (itineraryButtonAdded)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        width: 300.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            print("User inquired about the itinerary.");
                            await fetchUserItinerary();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9F76F9),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Inquire about Itinerary"),
                        ),
                      )),
                _buildInputField(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  void addItineraryButton(ChatViewModel viewModel) {
    viewModel.addItineraryButton(
      Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ElevatedButton(
            onPressed: () {
              print("User inquired about the itinerary.");
              // Handle the itinerary inquiry logic here
            },
            child: Text("Inquire about Itinerary"),
          )),
    );
    itineraryButtonAdded = true;
  }

  Future<void> fetchUserItinerary() async {
    // Assuming you have a ViewModel or service to handle the data
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      print("User not logged in.");
      return;
    }

    try {
      // Fetch itineraries from your provider/service (replace with your own logic)
      List<Map<String, dynamic>> itineraries =
          await ItineraryProvider().getUserItineraries(userId);

      if (itineraries.isEmpty) {
        print("No itineraries found.");
      } else {
        // Here you can show the itineraries to the user,
        // either by updating the UI or navigating to a new screen
        showItineraryDialog(itineraries);
      }
    } catch (e) {
      print("Error fetching itinerary: $e");
    }
  }

  Future<Map<String, dynamic>> fetchDayItinerary(String itineraryId) async {
    // Assume we are using Firebase Firestore
    final itineraryDoc = await FirebaseFirestore.instance
        .collection('DayItinerary')
        .where('itinerary_id', isEqualTo: itineraryId)
        .get();

    if (itineraryDoc.docs.isNotEmpty) {
      final itineraryData = itineraryDoc.docs.first.data();
      List<String> locationIds =
          List<String>.from(itineraryData['location_ids']);
      int dayNumber = itineraryData['day_number'];

      // Now use locationIds to fetch the location details
      List<Map<String, dynamic>> locations =
          await fetchLocations(locationIds, dayNumber);

      return {
        'itinerary_id': itineraryId,
        'day_number': dayNumber,
        'locations': locations,
      };
    } else {
      // Return an empty JSON or error message if no itinerary found
      return {'error': 'No locations added to this itinerary yet.'};
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocations(
      List<String> locationIds, int dayNumber) async {
    List<Map<String, dynamic>> locations = [];

    for (String locationId in locationIds) {
      final locationDoc = await FirebaseFirestore.instance
          .collection('ItineraryLocation')
          .doc(locationId)
          .get();

      if (locationDoc.exists) {
        final locationData = locationDoc.data();
        locations.add({
          'name': locationData?['name'],
          'latitude': locationData?['latitude'],
          'longitude': locationData?['longitude'],
          'dayNumber': dayNumber,
        });
      }
    }

    return locations;
  }

// Example: Show itinerary dialog with fetched data
  void showItineraryDialog(List<Map<String, dynamic>> itineraries) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Your Itineraries"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: itineraries.map((itinerary) {
              DateTime startDate;
              if (itinerary['start_date'] is int) {
                startDate = DateTime.fromMillisecondsSinceEpoch(
                    itinerary['start_date']);
              } else if (itinerary['start_date'] is String) {
                startDate = DateTime.parse(itinerary['start_date']);
              } else {
                startDate = DateTime.now();
              }

              // Calculate the end date by adding the number of days
              DateTime endDate =
                  startDate.add(Duration(days: itinerary['number_of_days']));

              // Format the dates into readable strings
              String formattedStartDate =
                  DateFormat('dd MMM yyyy').format(startDate);
              String formattedEndDate =
                  DateFormat('dd MMM yyyy').format(endDate);

              return ListTile(
                title: Text(
                  itinerary['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text("From: $formattedStartDate to $formattedEndDate"),
                onTap: () async {
                  print("Selected Itinerary ID: ${itinerary['id']}");

                  Map<String, dynamic> itineraryJson =
                      await fetchDayItinerary(itinerary['id']);

                  if (itineraryJson.containsKey('error')) {
                    // If itineraryJson contains 'error', show an alert dialog with the error message
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text(itineraryJson['error']),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(
                                  context), // Close the error dialog
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // If no error, print the itinerary data
                    print("Itinerary Data: $itineraryJson");
                    ChatViewModel viewModel = new ChatViewModel();
                    viewModel.sendItineraryToApi(
                        itineraryJson, FirebaseAuth.instance.currentUser!.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Itinerary uploaded successfully!', style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF9F76F9),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
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
