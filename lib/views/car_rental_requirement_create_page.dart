import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/car_rental_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class CarRentalRequirementCreatePage extends StatefulWidget {
  const CarRentalRequirementCreatePage({super.key});

  @override
  _CarRentalRequirementCreatePageState createState() =>
      _CarRentalRequirementCreatePageState();
}
class _CarRentalRequirementCreatePageState extends State<CarRentalRequirementCreatePage> {
  final FocusNode _pickupFocusNode = FocusNode(); // Focus node for pickup location
  final FocusNode _returnFocusNode = FocusNode(); // Focus node for return location
  DateTime? _pickupDate;

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _returnFocusNode.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  FirestoreService firestoreService = FirestoreService();
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController returnLocationController = TextEditingController();
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Car Rental Request Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          print(val);
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      placesAutoCompleteTextField(pickupLocationController, _pickupFocusNode, 'Pickup Location'),
                      const SizedBox(height: 15),
                      placesAutoCompleteTextField(returnLocationController, _returnFocusNode, 'Return Location'),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'pickup_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 5 * 365)),
                        inputType: InputType.date,
                        format: DateFormat('dd/MM/yyyy'),
                        decoration: const InputDecoration(
                          labelText: 'Pickup Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (val) {
                          setState(() {
                            _pickupDate = val; // Store the selected pickup date
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'return_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
                        inputType: InputType.date,
                        format: DateFormat('dd/MM/yyyy'),
                        decoration: const InputDecoration(
                          labelText: 'Return Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null) {
                            return 'Return date is required';
                          }
                          if (_pickupDate != null && val.isBefore(_pickupDate!)) {
                            return 'Return date cannot be earlier than pickup date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDropdown<String>(
                        name: 'car_type',
                        decoration: const InputDecoration(
                          labelText: 'Car Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(),
                        items: const [
                          DropdownMenuItem(value: 'sedan', child: Text('Sedan')),
                          DropdownMenuItem(value: 'suv', child: Text('SUV')),
                          DropdownMenuItem(value: 'hatchback', child: Text('Hatchback')),
                          DropdownMenuItem(value: 'coupe', child: Text('Coupe')),
                          DropdownMenuItem(value: 'convertible', child: Text('Convertible')),
                          DropdownMenuItem(value: 'minivan', child: Text('Mini Van')),
                          DropdownMenuItem(value: 'sportsCar', child: Text('Sports Car')),
                          DropdownMenuItem(value: 'electric', child: Text('Electric')),
                          DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                        ],
                        onChanged: (value) {
                          print("Selected car type: $value");
                        },
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'budget',
                        decoration: const InputDecoration(
                          labelText: 'Budget',
                          border: OutlineInputBorder(),
                          prefix: Text('RM '),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Price: $val');
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'additional_requirement',
                        decoration: const InputDecoration(
                          labelText: 'Additional Requirement',
                          border: OutlineInputBorder(),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loader
                  : MaterialButton(
                      padding: const EdgeInsets.all(15),
                      color: const Color.fromARGB(255, 159, 118, 249),
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final formValues = _formKey.currentState?.value;
                          print(formValues); // Print the form data

                          final carRentalRequirement = CarRentalRequirementModel(
                            id: '',
                            title: formValues?['title'] ?? '',
                            pickupLocation: pickupLocationController.text,
                            returnLocation: returnLocationController.text,
                            pickupDate: formValues?['pickup_date'] ?? DateTime.now(),
                            returnDate: formValues?['return_date'] ?? DateTime.now(),
                            budget: double.tryParse(formValues?['budget']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0.0') ?? 0.0,
                            createdAt: DateTime.now(),
                            additionalRequirement: formValues?['additional_requirement'] ?? '',
                            carType: CarType.values.firstWhere(
                              (e) => e.toString().split('.').last == formValues?['house_type'],
                              orElse: () => CarType.sedan, // Default value
                            ),
                            userDocId: FirebaseAuth.instance.currentUser!.uid,
                          );
                          try {
                            // Call firestore service to insert data
                            await firestoreService.insertDataWithAutoID(
                              'Car_Rental_Requirement',
                              carRentalRequirement.toMap(),
                            );

                            // Display success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Car Rental Requirement Successfully Created!'),
                                duration: Duration(seconds: 5),
                              ),
                            );

                            // Clear the text fields and reset the form
                            pickupLocationController.clear();
                            returnLocationController.clear();
                            _formKey.currentState?.reset(); // Reset the form fields

                            setState(() {
                              isLoading = false; // Reset loading state if needed
                            });
                          } catch (e) {
                            print('$e');
                          }
                        }
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  placesAutoCompleteTextField(TextEditingController textEditingController, FocusNode focusNode, String label) {
    return Container(
      child: GooglePlaceAutoCompleteTextField(
        containerVerticalPadding: 0,
        textEditingController: textEditingController,
        googleAPIKey: "AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8",
        inputDecoration: InputDecoration(
          hintText: "Search your location",
          labelText: '$label',
          border: OutlineInputBorder(),
        ),
        debounceTime: 400,
        countries: [],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lat.toString());
        },
        itemClick: (Prediction prediction) {
          textEditingController.text = prediction.description ?? "";
          textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: const Divider(),
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 7),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
        focusNode: focusNode,
      ),
    );
  }
}
