import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tripify/view_models/firestore_service.dart';

class AccommodationRequirementCreatePage extends StatefulWidget {
  @override
  _AccommodationRequirementCreatePageState createState() =>
      _AccommodationRequirementCreatePageState();
}

class _AccommodationRequirementCreatePageState
    extends State<AccommodationRequirementCreatePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  FirestoreService firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'title',
                        decoration: const InputDecoration(labelText: 'Title'),
                        onChanged: (val) {
                          print(val);
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'location',
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                        onChanged: (val) {
                          print(val);
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'checkin_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 5 * 365),
                        ),
                        inputType: InputType.date,
                        decoration:
                            const InputDecoration(labelText: 'Check-In Date'),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'checkout_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 5 * 365),
                        ),
                        inputType: InputType.date,
                        decoration:
                            const InputDecoration(labelText: 'Check-Out Date'),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'guest_num',
                        decoration:
                            const InputDecoration(labelText: 'Guest Number'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Guest Number: $val');
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'bed_num',
                        decoration:
                            const InputDecoration(labelText: 'Bed Number'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Bed Number: $val');
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDropdown<String>(
                        name: 'house_type',
                        decoration: const InputDecoration(
                          labelText: 'Select House Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'condo',
                            child: Text('Condo'),
                          ),
                          DropdownMenuItem(
                            value: 'semiD',
                            child: Text('Semi-D'),
                          ),
                          DropdownMenuItem(
                            value: 'banglow',
                            child: Text('Banglow'),
                          ),
                          DropdownMenuItem(
                            value: 'landed',
                            child: Text('Landed'),
                          ),
                          DropdownMenuItem(
                            value: 'hotel',
                            child: Text('Hotel'),
                          ),
                        ],
                        onChanged: (value) {
                          print("Selected house type: $value");
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'price',
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Price: $val');
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'additional_requirement',
                        decoration: const InputDecoration(
                          labelText: 'Additional Requirement',
                        ),
                        maxLines: null,
                        onChanged: (val) {
                          print(val);
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MaterialButton(
                padding: const EdgeInsets.all(15),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  _formKey.currentState?.saveAndValidate();
                  // firestoreService.insertData('Accommodation_Requirement', );
                },
                child: const Text('On Shelves'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
