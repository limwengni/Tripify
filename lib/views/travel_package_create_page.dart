import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';

class TravelPackageCreatePage extends StatefulWidget {
  const TravelPackageCreatePage({super.key});

  @override
  _TravelPackageCreatePageState createState() =>
      _TravelPackageCreatePageState();
}

class _TravelPackageCreatePageState extends State<TravelPackageCreatePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker picker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();

  List<XFile>? imagesSelected;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final List<String> imageUrls = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imageUrls
        .map(
          (item) => Container(
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(item),
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
        .toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilder(
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
                      onChanged: (val) {
                        debugPrint('Name: $val');
                      },
                    ),
                    const SizedBox(height: 10),
                    FormBuilderDateRangePicker(
                      name: 'travel_date',
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 5 * 365),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Travel Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'itinerary',
                      decoration: const InputDecoration(
                        labelText: 'Itinerary',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      onChanged: (val) {
                        debugPrint('Itinerary: $val');
                      },
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
                    //   CarouselSlider(
                    //     options: CarouselOptions(
                    //       aspectRatio: 2.0,
                    //       enlargeCenterPage: true,
                    //       enableInfiniteScroll: false,
                    //       initialPage: 2,
                    //       autoPlay: true,
                    //     ),
                    //     items: imageSliders,
                    //   ),
                    imagesSelected != null
                        ? CarouselSlider.builder(
                            itemCount: imagesSelected!
                                .length, // Use the length of image URLs
                            options: CarouselOptions(
                              viewportFraction: 1,
                              autoPlay: true,
                              enableInfiniteScroll: false,
                            ),
                            itemBuilder: (ctx, index, realIdx) {
                              return Image.file(
                                File(imagesSelected![index].path),
                                fit: BoxFit
                                    .cover, // Adjust the image scaling as needed
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
                          ))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                padding: const EdgeInsets.all(15),
                minWidth: double.infinity,
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  List<String>? downloadUrlList = [];
                  try {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final formValues = _formKey.currentState?.value;
                      final travelDate =
                          formValues?['travel_date'] as DateTimeRange;
                      if (imagesSelected != null) {
                        for (int i = 0; i < imagesSelected!.length; i++) {
                          String? downloadUrl = await _firebaseStorageService
                              .saveImageVideoToFirestore(
                                  file: File(imagesSelected![i].path),
                                  storagePath:
                                      '${currentUserId}/travel_package');
                          if (downloadUrl != null) {
                            downloadUrlList.add(downloadUrl);
                          }
                        }
                      }
                      print(formValues?['travel_package_name']);
                      TravelPackageModel travelPackageModel =
                          TravelPackageModel(
                        id: '',
                        name: formValues?['travel_package_name'] ?? '',
                        itinerary: formValues?['itinerary'] ?? '',
                        price:
                            double.tryParse(formValues?['price'] ?? '0') ?? 0.0,
                        startDate: travelDate.start,
                        endDate: travelDate.end,
                        quantity:
                            int.tryParse(formValues?['quantity'] ?? '0') ?? 0,
                        images: downloadUrlList ?? null,
                        createdBy: currentUserId,
                      );

                      await _firestoreService.insertDataWithAutoID(
                          'Travel_Packages', travelPackageModel.toMap());

                          ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Successfully On Shelves')));
                    } else {
                      debugPrint('Validation failed');
                    }
                  } catch (e) {
                    debugPrint('Failed to insert data: $e');
                  }
                },
                child: const Text(
                  'On Shelves',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
