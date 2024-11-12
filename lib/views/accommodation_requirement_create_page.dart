import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class AccommodationRequirementCreatePage extends StatefulWidget {
  @override
  _AccommodationRequirementCreatePageState createState() =>
      _AccommodationRequirementCreatePageState();
}

class _AccommodationRequirementCreatePageState
    extends State<AccommodationRequirementCreatePage> {
  final FocusNode _focusNode = FocusNode(); // Declare the FocusNode

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
                        decoration: const InputDecoration(
                          labelText: 'Check-Out Date',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        validator: FormBuilderValidators.required(),
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
                        validator: FormBuilderValidators.required(),
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
                        validator: FormBuilderValidators.required(),
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
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderTextField(
                        name: 'additional_requirement',
                        decoration: const InputDecoration(
                          labelText: 'Additional Requirement',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        maxLines: 3,
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
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final formValues = _formKey.currentState?.value;
                    print(formValues); // Print the form data

                    final accommodationRequirement = AccommodationRequirement(
                      id: '',
                      title: formValues?['title'] ?? '',
                      location: controller.text,
                      checkinDate:
                          formValues?['checkin_date'] ?? DateTime.now(),
                      checkoutDate:
                          formValues?['checkout_date'] ?? DateTime.now(),
                      guestNum:
                          int.tryParse(formValues?['guest_num'] ?? '') ?? 0,
                      bedNum: int.tryParse(formValues?['bed_num'] ?? '') ?? 0,
                      budget: double.tryParse(formValues?['budget']
                                  ?.replaceAll(RegExp(r'[^0-9.]'), '') ??
                              '0.0') ??
                          0.0,
                      additionalRequirement:
                          formValues?['additional_requirement'] ?? '',
                      houseType: HouseType.values.firstWhere(
                        (e) => e.toString() == formValues?['house_type'],
                        orElse: () => HouseType.condo,
                      ),
                      userDocId: '',
                    );
                    // firestoreService.insertData('Accommodation_Requirement',
                    //     accommodationRequirement.toMap());
                    print('ID: ${accommodationRequirement.id}');
                    print('Title: ${accommodationRequirement.title}');
                    print('Location: ${accommodationRequirement.location}');
                    print(
                        'Check-In Date: ${accommodationRequirement.checkinDate}');
                    print(
                        'Check-Out Date: ${accommodationRequirement.checkoutDate}');
                    print('Guest Number: ${accommodationRequirement.guestNum}');
                    print('Bed Number: ${accommodationRequirement.bedNum}');
                    print('Budget: RM ${accommodationRequirement.budget}');
                    print(
                        'Additional Requirement: ${accommodationRequirement.additionalRequirement}');
                    print('House Type: ${accommodationRequirement.houseType}');
                    print('User Doc ID: ${accommodationRequirement.userDocId}');
                  }
                },
                child: const Text('On Shelves'),
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
        focusNode: _focusNode, // Attach FocusNode to the widget
      ),
    );
  }

// placesAutoCompleteTextField() {
//     return Container(
//       child: GooglePlaceAutoCompleteTextField(
//         containerVerticalPadding: 0,
//         textEditingController: controller,
//         googleAPIKey: "YOUR_GOOGLE_API_KEY",  // Make sure to use your actual API Key
//         inputDecoration: const InputDecoration(
//           hintText: "Search your location",
//           labelText: 'Location',
//           border: OutlineInputBorder(),
//         ),
//         debounceTime: 400,
//         countries: [],
//         isLatLngRequired: true,
//         getPlaceDetailWithLatLng: (Prediction prediction) {
//           print("placeDetails: " + prediction.lat.toString());
//         },
//         itemClick: (Prediction prediction) {
//           controller.text = prediction.description ?? "";
//           controller.selection = TextSelection.fromPosition(
//               TextPosition(offset: prediction.description?.length ?? 0));
//         },
//         seperatedBuilder: Divider(),
//         // Optional customization of the list view item builder
//         itemBuilder: (context, index, Prediction prediction) {
//           return Container(
//             padding: EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on),
//                 SizedBox(width: 7),
//                 Expanded(child: Text("${prediction.description ?? ""}"))
//               ],
//             ),
//           );
//         },
//         isCrossBtnShown: true,
//         focusNode: _focusNode, // Attach FocusNode to the widget
//       ),
//     );
//   }
}
