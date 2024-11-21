// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:tripify/models/conversation_model.dart';
// import 'package:tripify/view_models/firestore_service.dart';

// // class ConversationCard extends StatefulWidget {
//   final ConversationModel conversation;
//   const ConversationCard({super.key, required this.conversation});

//   @override
//   _ConversationCardState createState() => _ConversationCardState();
// }

// class _ConversationCardState extends State<ConversationCard> {
//   late Future<String?> conversationPicFuture;
//   late Future<String?> conversationName;

//   @override
//   void initState() {
//     super.initState();
//      _fetchConversationPic();
//   }

//   void _fetchConversationPic() async {
//     if (!widget.conversation.isGroup) {
//       FirestoreService firestoreService = FirestoreService();
//       for (var participant in widget.conversation.participants) {
//         if (participant != FirebaseAuth.instance.currentUser!.uid) {
//           Map<String, dynamic>? userData =
//               await firestoreService.getDataById('User', participant);
//           conversationPicFuture =  userData?['profile_picture'] as Future<String?>;
//           conversationName =  userData?['username'] as Future<String?>;

//         }
//       }
//     }
//     return null; // Default if no picture is found or it's a group
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: conversationPicFuture,
//       builder: (context, snapshot) {
//         String defaultImageUrl =
//             'https://developers.google.com/static/maps/documentation/streetview/images/error-image-generic.png'; // Replace with your default image URL
//         String imageUrl = snapshot.data ?? defaultImageUrl;

//         return Card(
//           child: SizedBox(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.grey.shade200,
//                     child: ClipOval(
//                       child: Image.network(
//                         imageUrl,
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         conversationName as String,
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       const Text('message...'),
//                     ],
//                   ),
//                   const Spacer(),
//                   Column(
//                     children: [
//                       const Row(
//                         children: [
//                           Text('12:01 PM'),
//                           Icon(
//                             Icons.push_pin,
//                             size: 15,
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 30,
//                         height: 30,
//                         decoration: const BoxDecoration(
//                           color: Colors.blue,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: const Text(
//                           '9+',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
