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

class _CarRentalRequirementCreatePageState
    extends State<CarRentalRequirementCreatePage> {
  final FocusNode _pickupFocusNode =
      FocusNode(); // Focus node for pickup location
  final FocusNode _returnFocusNode =
      FocusNode(); // Focus node for return location

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Car Rental Request Create'),
      ),
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
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'title',
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        onChanged: (val) {
                          print(val);
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      placesAutoCompleteTextField(
                          pickupLocationController, _pickupFocusNode),
                      const SizedBox(height: 15),
                      placesAutoCompleteTextField(
                          returnLocationController, _returnFocusNode),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'pickup_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 5 * 365),
                        ),
                        inputType: InputType.date,
                        format: DateFormat(
                            'dd/MM/yyyy'), // Set the format to dd/MM/yyyy

                        decoration: const InputDecoration(
                          labelText: 'Pickup Date',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'return_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 5 * 365),
                        ),
                        inputType: InputType.date,
                        format: DateFormat(
                            'dd/MM/yyyy'), // Set the format to dd/MM/yyyy

                        decoration: const InputDecoration(
                          labelText: 'Return Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDropdown<String>(
                        name: 'car_type',
                        decoration: const InputDecoration(
                          labelText: 'Car Type',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        validator: FormBuilderValidators.required(),
                        items: const [
                          DropdownMenuItem(
                            value: 'sedan',
                            child: Text('Sedan'),
                          ),
                          DropdownMenuItem(
                            value: 'suv',
                            child: Text('SUV'),
                          ),
                          DropdownMenuItem(
                            value: 'hatchback',
                            child: Text('Hatchback'),
                          ),
                          DropdownMenuItem(
                            value: 'coupe',
                            child: Text('Coupe'),
                          ),
                          DropdownMenuItem(
                            value: 'convertible',
                            child: Text('Convertible'),
                          ),
                          DropdownMenuItem(
                            value: 'minivan',
                            child: Text('Mini Van'),
                          ),
                          DropdownMenuItem(
                            value: 'sportsCar',
                            child: Text('Sports Car'),
                          ),
                          DropdownMenuItem(
                            value: 'electric',
                            child: Text('Electric'),
                          ),
                          DropdownMenuItem(
                            value: 'hybird',
                            child: Text('Hybird'),
                          ),
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
                          border: OutlineInputBorder(), // Default border color
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
                      budget: double.tryParse(formValues?['budget']
                                  ?.replaceAll(RegExp(r'[^0-9.]'), '') ??
                              '0.0') ??
                          0.0,
                      additionalRequirement:
                          formValues?['additional_requirement'] ?? '',
                      carType: CarType.values.firstWhere(
                        (e) =>
                            e.toString().split('.').last ==
                            formValues?['house_type'],
                        orElse: () => CarType.sedan, // Default value
                      ),
                      userDocId: FirebaseAuth.instance.currentUser!.uid,
                    );
                    try {
                      await firestoreService.insertDataWithAutoID(
                        'Car_Rental_Requirement',
                        carRentalRequirement.toMap(),
                      );

                      Navigator.pop(context,
                          'Car rental requirement created successfully');
                    } catch (e) {
                      print('${e}');
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  placesAutoCompleteTextField(
      TextEditingController textEditingController, FocusNode focusNode) {
    return Container(
      child: GooglePlaceAutoCompleteTextField(
        containerVerticalPadding: 0,
        textEditingController: textEditingController,
        googleAPIKey: "AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8",
        inputDecoration: const InputDecoration(
          hintText: "Search your location",
          labelText: 'Location',
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
                const SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
        focusNode: focusNode, //
      ),
    );
  }
}
