import 'package:flutter/material.dart';
import 'package:tripify/models/car_rental_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/car_rental_requirement_card_list.dart';

class CarRentalRequirementPage extends StatefulWidget {
  const CarRentalRequirementPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CarRentalRequriementPageState();
  }
}

class _CarRentalRequriementPageState
    extends State<CarRentalRequirementPage> {
 List<CarRentalRequirementModel> carRentalRequirementList = [];

  @override
  void initState() {
    super.initState();
    fetchCarRentalRequirements();
  }

  Future<void> fetchCarRentalRequirements() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> data =
        await firestoreService.getData('Car_Rental_Requirement');

    if (mounted) {
      setState(() {
        carRentalRequirementList = data
            .map((item) => CarRentalRequirementModel.fromMap(item))
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
              child:CarRentalRequirementCardList(carRentalRequirmentsList: carRentalRequirementList),
            ),
          ],
        ),
    );
  }
}
