import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class AccommodationRequirementCreatePage extends StatefulWidget {
  const AccommodationRequirementCreatePage({super.key});

  @override
  _AccommodationRequirementCreatePageState createState() =>
      _AccommodationRequirementCreatePageState();
}

class _AccommodationRequirementCreatePageState
    extends State<AccommodationRequirementCreatePage> {
  final FocusNode _focusNode = FocusNode(); // Declare the FocusNode
  bool isLoading = false; // Track loading state

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the FocusNode to avoid memory leaks
    super.dispose();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  FirestoreService firestoreService = FirestoreService();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Accommodation Request Create'),
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
                      placesAutoCompleteTextField(),
                      const SizedBox(height: 15),
                      FormBuilderDateTimePicker(
                        name: 'checkin_date',
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 5 * 365),
                        ),
                        inputType: InputType.date,
                        format: DateFormat(
                            'dd/MM/yyyy'), // Set the format to dd/MM/yyyy

                        decoration: const InputDecoration(
                          labelText: 'Check-In Date',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        validator: FormBuilderValidators.required(),
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
                        format: DateFormat(
                            'dd/MM/yyyy'), // Set the format to dd/MM/yyyy

                        decoration: const InputDecoration(
                          labelText: 'Check-Out Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'This field is required'),
                          (value) {
                            final checkinDate = _formKey
                                .currentState?.fields['checkin_date']?.value;

                            if (checkinDate != null && value != null) {
                              if (value.isBefore(checkinDate)) {
                                return 'Checkout date must be after check-in date';
                              }
                            }
                            return null; // Validation passed
                          },
                        ]),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'guest_num',
                        decoration: const InputDecoration(
                          labelText: 'Guest Number',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Guest Number: $val');
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Guest Number is required'),
                          FormBuilderValidators.integer(
                              errorText: 'Please enter a valid number'),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'bed_num',
                        decoration: const InputDecoration(
                          labelText: 'Bed Number',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          print('Bed Number: $val');
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Guest Number is required'),
                          FormBuilderValidators.integer(
                              errorText: 'Please enter a valid number'),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDropdown<String>(
                        name: 'house_type',
                        decoration: const InputDecoration(
                          labelText: 'House Type',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        validator: FormBuilderValidators.required(),
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
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Guest Number is required'),
                          FormBuilderValidators.numeric(
                              errorText: 'Please enter a valid number'),
                          FormBuilderValidators.positiveNumber(
                              errorText: 'Please enter a positive number'),
                        ]),
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
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Show loader
                  : MaterialButton(
                      padding: const EdgeInsets.all(15),
                      color: const Color.fromARGB(255, 159, 118, 249),
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          setState(() {
                            isLoading = true; // Start loading
                          });
                          final formValues = _formKey.currentState?.value;

                          final accommodationRequirement =
                              AccommodationRequirementModel(
                            createdAt: DateTime.now(),
                            id: '',
                            title: formValues?['title'] ?? '',
                            location: controller.text,
                            checkinDate:
                                formValues?['checkin_date'] ?? DateTime.now(),
                            checkoutDate:
                                formValues?['checkout_date'] ?? DateTime.now(),
                            guestNum:
                                int.tryParse(formValues?['guest_num'] ?? '') ??
                                    0,
                            bedNum:
                                int.tryParse(formValues?['bed_num'] ?? '') ?? 0,
                            budget: double.tryParse(formValues?['budget']
                                        ?.replaceAll(RegExp(r'[^0-9.]'), '') ??
                                    '0.0') ??
                                0.0,
                            additionalRequirement:
                                formValues?['additional_requirement'] ?? '',
                            houseType: HouseType.values.firstWhere(
                              (e) =>
                                  e.toString().split('.').last ==
                                  formValues?['house_type'],
                              orElse: () => HouseType.condo, // Default value
                            ),
                            userDocId: FirebaseAuth.instance.currentUser!.uid,
                          );
                          try {
                            await firestoreService.insertDataWithAutoID(
                              'Accommodation_Requirement',
                              accommodationRequirement.toMap(),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Accommodation Requirement Successfully Created!'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          } catch (e) {
                            print('${e}');
                          } finally {
                            // Clear form inputs and controller
                            _formKey.currentState
                                ?.reset(); // Reset the FormBuilder fields
                            controller.clear(); // Clear the location text field
                            setState(() {
                              isLoading = false; // Stop loading
                            });
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

  placesAutoCompleteTextField() {
    return Container(
      child: GooglePlaceAutoCompleteTextField(
        containerVerticalPadding: 0,
        textEditingController: controller,
        googleAPIKey: "AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8",
        inputDecoration: const InputDecoration(
          // hintText: "Search your location",
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
          controller.text = prediction.description ?? "";
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: Divider(),

        // OPTIONAL// If you want to customize list view item builder
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(
                  width: 7,
                ),
                Expanded(child: Text("${prediction.description ?? ""}"))
              ],
            ),
          );
        },
        isCrossBtnShown: true,
        focusNode: _focusNode,
      ),
    );
  }
}
