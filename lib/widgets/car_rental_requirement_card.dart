import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/car_rental_requirement_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/views/travel_package_purchased_repository_page.dart';

class CarRentalRequirementCard extends StatefulWidget {
  final CarRentalRequirementModel carRentalRequirement;
  const CarRentalRequirementCard(
      {super.key, required this.carRentalRequirement});

  @override
  State<StatefulWidget> createState() {
    return _CarRentalRequirementCardState();
  }
}

class _CarRentalRequirementCardState extends State<CarRentalRequirementCard> {
  FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? conversationMap;
  @override
  Widget build(BuildContext context) {
    List<String> participants = [
      currentUserId,
      widget.carRentalRequirement.userDocId
    ];

    return Card(
        child: SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.carRentalRequirement.title,
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

                                conversation = ConversationModel.fromMap(conversationMap!);
                      }else{
                                                        conversation = ConversationModel.fromMap(conversationMap!);

                      }

                      Map<String, dynamic>? user =
                          await _firestoreService.getDataById(
                              'User', widget.carRentalRequirement.userDocId);

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
                            chatPic: conversationPic!, // Use 'conversationPic' or default to an empty string
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
                TableRow(children: [
                  const Text("Pickup Location:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child:
                        Text("${widget.carRentalRequirement.pickupLocation}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Return Location:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child:
                        Text("${widget.carRentalRequirement.returnLocation}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Pickup Date:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child: Text("${widget.carRentalRequirement.pickupDate}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Return Date:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child: Text("${widget.carRentalRequirement.returnDate}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Car Type:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child: Text("${widget.carRentalRequirement.carType}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Budget:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child: Text("${widget.carRentalRequirement.budget}"),
                  ),
                ]),
                TableRow(children: [
                  const Text("Additional Requirement:"),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0), // Add space here
                    child: Text(
                        "${widget.carRentalRequirement.additionalRequirement}"),
                  ),
                ]),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
