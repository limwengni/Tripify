import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/receipt_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class ReceiptCard extends StatefulWidget {
  final ReceiptModel receipt;
  final String currentUserId;
  const ReceiptCard(
      {super.key, required this.receipt, required this.currentUserId});

  @override
  _ReceiptCardState createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<ReceiptCard> {
  FirestoreService _firestoreService = FirestoreService();
  UserModel? travelCompanyUser;
  bool userLoaded = false;
  bool save = false;
  TravelPackageModel? travelPackage;

  @override
  void initState() {
    print('hello');
    fetchTravelPackage();
    super.initState();
  }

  void fetchTravelPackage() async {
    Map<String, dynamic>? travelPackageMap = await _firestoreService
        .getDataById('Travel_Packages', widget.receipt.travelPackageId);

    print(travelPackageMap);
    if (travelPackageMap != null) {
      setState(() {
        travelPackage = TravelPackageModel.fromMap(travelPackageMap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> ticketNoList = widget.receipt.ticketIdList;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receipt ID: ${widget.receipt.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Makes the text bold
                  fontSize: 17, // Adjust size for a title
                ),
              ),
              const SizedBox(height: 5),
              // Show CircularProgressIndicator if travelPackage is null
              travelPackage == null
                  ? Container(
                      padding: const EdgeInsets.all(16.0),
                      child: const CircularProgressIndicator(),
                    )
                  : Text(
                      'Travel Package: ' + travelPackage!.name,
                      style: const TextStyle(fontSize: 16),
                    ),
              const SizedBox(height: 5),
              Text('Quantity: ${ticketNoList.length}'),
              const SizedBox(height: 5),
              Text('Ticket No: '),
              const SizedBox(height: 5),

              ...ticketNoList.map((ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text('- $ticket'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // void changeSave() async {
  //   if (save == true) {
  //     await _firestoreService.updateMapField('Travel_Packages',
  //         widget.travelPackage.id, 'save_num', widget.currentUserId, false);
  //   } else {
  //     await _firestoreService.updateMapField('Travel_Packages',
  //         widget.travelPackage.id, 'save_num', widget.currentUserId, true);
  //   }
  //   setState(() {
  //     save = !save;
  //   });
  // }
}
