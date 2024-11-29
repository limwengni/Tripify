import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class TravelPackageCard extends StatefulWidget {
  final TravelPackageModel travelPackage;

  const TravelPackageCard({super.key, required this.travelPackage});

  @override
  _TravelPackageCardState createState() => _TravelPackageCardState();
}

class _TravelPackageCardState extends State<TravelPackageCard> {
  // You can manage state here, for example, for image index or any dynamic behavior
  int _currentImageIndex = 0;
  FirestoreService _firestoreService = FirestoreService();
  UserModel? user;
  bool userLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchTravelCompany();
  }

  void fetchTravelCompany() async {
    Map<String, dynamic>? userMap;
    userMap = await _firestoreService.getDataById(
        'User', widget.travelPackage.createdBy);
    if (userMap != null) {
      print('userMap*********************************' + userMap.toString());
    } else {
      print('***********************************');
    }
    setState(() {
      if (userMap != null) {
        user = UserModel.fromMap(userMap, userMap['id']);

        print(user);
        if (user != null) {
          userLoaded = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){ Navigator.push(context, MaterialPageRoute(builder: (context)=>TravelPackageDetailsPage(travelPackage: widget.travelPackage)));} ,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12.0), // Same corner radius as the Card
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: Container(
                height: 150,
                width:
                    double.infinity, // Ensures the container takes the full width
                child: CarouselSlider.builder(
                  itemCount: widget.travelPackage.images!
                      .length, // Use the length of image URLs
                  options: CarouselOptions(
                    viewportFraction: 1,
                    autoPlay: true,
                    enableInfiniteScroll: false,
                 
                  ),
                  itemBuilder: (ctx, index, realIdx) {
                    return Image.network(
                      widget.travelPackage.images![index],
                      width:
                          double.infinity, // Make sure the image takes full width
                      fit: BoxFit.cover, // Scale the image to cover the container
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.travelPackage.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                            '${DateFormat('yyyy-MM-dd').format(widget.travelPackage.startDate)} - ${DateFormat('yyyy-MM-dd').format(widget.travelPackage.endDate)}'),
                        const SizedBox(height: 5),
                        user != null
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15, // Adjust the radius as needed
                                    backgroundImage:
                                        NetworkImage(user!.profilePic),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 10),
                                   Text(user!.username),
                                ],
                              )
                            : const Row(
                                children: [
                                  Text('loading'),
                                ],
                              )
                      ],
                    ),
                  ),
                  Text(
                    'RM100',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

