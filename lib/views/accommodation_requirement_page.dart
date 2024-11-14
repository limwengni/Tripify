import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/accommodation_requirement_card_list.dart';

class AccommodationRequirementPage extends StatefulWidget {
  const AccommodationRequirementPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementPageState();
  }
}

class _AccommodationRequirementPageState
    extends State<AccommodationRequirementPage> {
 List<AccommodationRequirementModel> accommodationsList = [];

  @override
  void initState() {
    super.initState();
    fetchAccommodationRequirements();
  }

  Future<void> fetchAccommodationRequirements() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> data =
        await firestoreService.getData('Accommodation_Requirement');

    // Parse the data into your model
    if (mounted) {
      setState(() {
        accommodationsList = data
            .map((item) => AccommodationRequirementModel.fromMap(item))
            .toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return   Center(
        child: Column(
          children: [
            Expanded(
              child: AccommodationRequirementCardList(accommodationsList: accommodationsList),
            ),
          ],
        ),
    );
  }
}
