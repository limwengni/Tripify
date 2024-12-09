import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';

class NewTravelPackageCreatePage extends StatefulWidget {
  const NewTravelPackageCreatePage({super.key});

  @override
  _NewTravelPackageCreatePageState createState() =>
      _NewTravelPackageCreatePageState();
}

class _NewTravelPackageCreatePageState
    extends State<NewTravelPackageCreatePage> {
  final controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> daysList = [];
  final Map<int, List<String>> dayNotes = {}; // Store notes for each day
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker picker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();
  bool _isLoading = false; // Add a state variable to track loading status

  List<XFile>? imagesSelected;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormBuilderTextField(
                        name: 'travel_package_name',
                        decoration: const InputDecoration(
                          labelText: 'Travel Package Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onChanged: (val) {
                          debugPrint('Name: $val');
                        },
                      ),
                      const SizedBox(height: 10),
                      FormBuilderDateRangePicker(
                        name: 'travel_date',
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 5 * 365)),
                        decoration: const InputDecoration(
                          labelText: 'Travel Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onChanged: (value) {
                          if (value != null &&
                              value.start != null &&
                              value.end != null) {
                            setState(() {
                              selectedStartDate = value.start;
                              selectedEndDate = value.end;
                              daysList =
                                  _generateDaysList(value.start!, value.end!);
                            });
                          }
                        },
                      ),
                      // Display the selected dates
                      // if (selectedStartDate != null && selectedEndDate != null)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //     child: Text(
                      //       'Selected dates: ${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} - ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)}',
                      //       style: TextStyle(fontWeight: FontWeight.bold),
                      //     ),
                      //   ),
                      const SizedBox(height: 10),
                      Text(
                        'Itinerary',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),

                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 235, 235, 235),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            placesAutoCompleteTextField(),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: daysList.length,
                              itemBuilder: (context, index) {
                                String day = daysList[index];
                                return ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(day)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    children: dayNotes[index]?.map((note) {
                                          return Container(
                                            margin:
                                                EdgeInsets.fromLTRB(0, 0, 0, 3),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 1, 1, 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    note,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                  IconButton(
                                                    icon: Icon(Icons.close),
                                                    onPressed: () {
                                                      // Remove the note when "X" is pressed
                                                      _removeNoteFromDay(
                                                          index, note);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList() ??
                                        [],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'quantity',
                        decoration: const InputDecoration(
                          labelText: 'Quantity Available',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          debugPrint('Quantity: $val');
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.integer()
                        ]),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'price',
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          debugPrint('Price: $val');
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric()
                        ]),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text('Images'),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              final List<XFile> images =
                                  await picker.pickMultiImage();

                              setState(() {
                                if (imagesSelected != null) {
                                  imagesSelected?.addAll(images);
                                } else {
                                  imagesSelected = images;
                                }
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      imagesSelected != null
                          ? CarouselSlider.builder(
                              itemCount: imagesSelected!.length,
                              options: CarouselOptions(
                                viewportFraction: 1,
                                autoPlay: true,
                                enableInfiniteScroll: false,
                              ),
                              itemBuilder: (ctx, index, realIdx) {
                                return Image.file(
                                  File(imagesSelected![index].path),
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Center(
                              child: Container(
                              height: 400,
                              width: 400,
                              color: Colors.grey,
                              child: const Center(
                                  child: Text(
                                'You can add some picture',
                                textAlign: TextAlign.center,
                              )),
                            )),

                      const SizedBox(height: 20),
                      MaterialButton(
                        padding: const EdgeInsets.all(15),
                        minWidth: double.infinity,
                        color: const Color.fromARGB(255, 159, 118, 249),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true; // Show loading indicator
                                });
                                List<String>? downloadUrlList = [];
                                try {
                                  if (_formKey.currentState
                                          ?.saveAndValidate() ??
                                      false) {
                                    if (imagesSelected != null) {
                                      final formValues =
                                          _formKey.currentState?.value;
                                      final travelDate =
                                          formValues?['travel_date']
                                              as DateTimeRange;
                                      Map<String, String?>? ticketIdMap;
                                      ticketIdMap ??= {};

                                      if (imagesSelected != null) {
                                        for (int i = 0;
                                            i < imagesSelected!.length;
                                            i++) {
                                          String? downloadUrl =
                                              await _firebaseStorageService
                                                  .saveImageVideoToFirestore(
                                            file: File(imagesSelected![i].path),
                                            storagePath:
                                                '${currentUserId}/travel_package',
                                          );
                                          if (downloadUrl != null) {
                                            downloadUrlList.add(downloadUrl);
                                          }
                                        }
                                      }

                                      ConversationModel conversationModel =
                                          ConversationModel(
                                        id: '',
                                        participants: [currentUserId],
                                        isGroup: true,
                                        updatedAt: DateTime.now(),
                                        groupName:
                                            formValues?['travel_package_name'],
                                        host: currentUserId,
                                        unreadMessage: {currentUserId: 0},
                                      );
                                      String conversationId =
                                          await _firestoreService
                                              .insertDataWithReturnAutoID(
                                        'Conversations',
                                        conversationModel.toMap(),
                                      );

                                      NewTravelPackageModel travelPackageModel =
                                          NewTravelPackageModel(
                                              id: '',
                                              name: formValues?[
                                                      'travel_package_name'] ??
                                                  '',
                                              itinerary: dayNotes,
                                              price: double.tryParse(
                                                      formValues?['price'] ??
                                                          '0') ??
                                                  0.0,
                                              startDate: travelDate.start,
                                              endDate: travelDate.end,
                                              quantity: int.tryParse(
                                                      formValues?['quantity'] ??
                                                          '0') ??
                                                  0,
                                              images: downloadUrlList ?? null,
                                              createdBy: currentUserId,
                                              groupChatId: conversationId,
                                              quantityAvailable: int.tryParse(
                                                      formValues?['quantity'] ??
                                                          '0') ??
                                                  0,
                                              createdAt: DateTime.now(),
                                              ticketIdNumMap: ticketIdMap);

                                      final id = await _firestoreService
                                          .insertDataWithReturnAutoID(
                                        'New_Travel_Packages',
                                        travelPackageModel.toMap(),
                                      );

                                      if (id != null) {
                                        int quantity =
                                            int.parse(formValues!['quantity']);
                                        for (int i = 0; i < quantity; i++) {
                                          ticketIdMap.addEntries(
                                              [MapEntry('${id}_${i}', '')]);
                                        }
                                      }

                                      _firestoreService.updateField(
                                          'New_Travel_Packages',
                                          id,
                                          'ticket_id_map',
                                          ticketIdMap);

                                      // Clear all inputs and states
                                      _formKey.currentState?.reset();
                                      setState(() {
                                        imagesSelected = null;
                                        downloadUrlList = [];
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Successfully On Shelves'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select some images!'),
                                          duration: Duration(seconds: 5),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Display the validation errors
                                    debugPrint('Validation failed');
                                    _formKey.currentState?.fields
                                        .forEach((key, value) {
                                      if (value?.hasError ?? false) {
                                        // Here you can print the validation error
                                        debugPrint(
                                            'Validation failed for $key: ${value?.errorText}');
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please fill all required fields.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Failed to insert data: $e');
                                } finally {
                                  setState(() {
                                    _isLoading =
                                        false; // Hide loading indicator
                                  });
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'On Shelves',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  List<String> _generateDaysList(DateTime startDate, DateTime endDate) {
    List<String> days = [];
    int numberOfDays = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < numberOfDays; i++) {
      days.add(
          'Day ${i + 1}: ${DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: i)))}');
    }
    return days;
  }

  placesAutoCompleteTextField() {
    return Container(
      color: Colors.white,
      child: GooglePlaceAutoCompleteTextField(
        containerVerticalPadding: 0,
        textEditingController: controller,
        googleAPIKey:
            "AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8", // Replace with your key
        inputDecoration: const InputDecoration(
          labelText: 'Location',
          border: OutlineInputBorder(),
        ),
        debounceTime: 400,
        countries: [],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails: " + prediction.lat.toString());
        },
        itemClick: (Prediction prediction) {
          controller.text = prediction.description ?? "";
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));

          // Show the dialog to select the day
          _showDaySelectionDialog(prediction.description ?? "");
        },
        seperatedBuilder: Divider(),
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
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

  // Show the dialog to select which day the location should be added to
  void _showDaySelectionDialog(String location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Day Select'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select a day for $location'),
              DropdownButton<int>(
                hint: Text('Select a day'),
                onChanged: (int? selectedDayIndex) {
                  if (selectedDayIndex != null) {
                    setState(() {
                      // Add the location to the selected day's notes
                      dayNotes
                          .putIfAbsent(selectedDayIndex, () => [])
                          .add(location);
                    });
                    Navigator.pop(context); // Close the dialog after selecting
                  }
                },
                items: List.generate(
                  daysList.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(daysList[index]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Remove a note from the selected day
  void _removeNoteFromDay(int dayIndex, String note) {
    setState(() {
      dayNotes[dayIndex]?.remove(note);
      if (dayNotes[dayIndex]?.isEmpty ?? true) {
        dayNotes.remove(dayIndex); // Remove the day if no notes left
      }
    });
  }
}
