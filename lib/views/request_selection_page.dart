import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripify/main.dart';
import 'package:tripify/views/accommodation_requirement_create_page.dart';
import 'package:tripify/views/car_rental_requirement_create_page.dart';

class RequestSelectionPage extends StatelessWidget {
  const RequestSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainPageState = context.findAncestorStateOfType<MainPageState>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                // mainPageState?.onItemTapped(4); // Navigate to Option1Page
                Navigator.push(context, MaterialPageRoute(builder: (builder)=> AccommodationRequirementCreatePage()));
              },
              color: const Color.fromARGB(255, 159, 118, 249)
,
              textColor: Colors.white,
              minWidth: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text('Accommodation Requirement Page'),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              onPressed: () {
                // mainPageState?.onItemTapped(5); // Navigate to Option1Page
                Navigator.push(context, MaterialPageRoute(builder: (builder)=> CarRentalRequirementCreatePage()));
              },
              color: const Color.fromARGB(255, 159, 118, 249),
              textColor: Colors.white,
              minWidth: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text('Car Rental Requirement Page'),
            ),
          ],
        ),
      ),
    );
  }
}
