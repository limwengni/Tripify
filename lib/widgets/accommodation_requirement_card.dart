import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';

class AccommodationRequirementCard extends StatefulWidget {
  final AccommodationRequirementModel accommodationRequirement;
  const AccommodationRequirementCard(
      {super.key, required this.accommodationRequirement});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementCardState();
  }
}

class _AccommodationRequirementCardState
    extends State<AccommodationRequirementCard> {
  FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? conversationMap;
  @override
  Widget build(BuildContext context) {
    List<String> participants = [
      currentUserId,
      widget.accommodationRequirement.userDocId
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.accommodationRequirement.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                    onPressed: () async {
                      String? conversationPic;
                      ConversationModel? conversation;

                      conversationMap =
                          await _firestoreService.getFilteredDataDirectly(
                              'Conversations', 'participants', participants);

                      if (conversationMap == null) {
                        ConversationModel conversationModel = ConversationModel(
                          id: '',
                          participants: participants,
                          isGroup: false,
                          updatedAt: DateTime.now(),
                          host: currentUserId,
                          unreadMessage: {
                            participants[0]: 0,
                            participants[1]: 0
                          },
                        );
                        await _firestoreService.insertDataWithAutoID(
                            'Conversations', conversationModel.toMap());

                        conversationMap =
                            await _firestoreService.getFilteredDataDirectly(
                                'Conversations', 'participants', participants);

                        conversation =
                            ConversationModel.fromMap(conversationMap!);
                      } else {
                        conversation =
                            ConversationModel.fromMap(conversationMap!);
                      }

                      Map<String, dynamic>? user =
                          await _firestoreService.getDataById('User',
                              widget.accommodationRequirement.userDocId);

                      if (user != null) {
                        conversationPic = user['profile_picture'];
                      }

                      print('last');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => ChatPage(
                            conversation: conversation!,
                            currentUserId: currentUserId,
                            chatPic:
                                conversationPic!, // Use 'conversationPic' or default to an empty string
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_right_outlined,
                      size: 30,
                    )),
              ],
            ),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                
                TableRow(
                  children: [
                    const Text("Location:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text(widget.accommodationRequirement.location),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Check-in Date:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text('${DateFormat('yyyy-MM-dd').format(widget.accommodationRequirement.checkinDate)}')),
                    
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Check-out Date:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text('${DateFormat('yyyy-MM-dd').format(widget.accommodationRequirement.checkoutDate)}')),
                      
            
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Guest Number:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text(
                          widget.accommodationRequirement.guestNum.toString()),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Bed Number:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text(
                          widget.accommodationRequirement.bedNum.toString()),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Budget:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text(
                          widget.accommodationRequirement.budget.toString()),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    const Text("Additional Requirement:"),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, bottom: 5), // Add space here
                      child: Text(widget
                          .accommodationRequirement.additionalRequirement),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
