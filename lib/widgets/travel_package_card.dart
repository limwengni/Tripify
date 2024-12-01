import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class TravelPackageCard extends StatefulWidget {
  final TravelPackageModel travelPackage;
  final String currentUserId;
  const TravelPackageCard({super.key, required this.travelPackage,required this.currentUserId});

  @override
  _TravelPackageCardState createState() => _TravelPackageCardState();
}

class _TravelPackageCardState extends State<TravelPackageCard> {
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPackageDetailsPage(
              travelPackage: widget.travelPackage,
              currentUserId: widget.currentUserId,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    child: CarouselSlider.builder(
                      itemCount: widget.travelPackage.images!.length,
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        enableInfiniteScroll: false,
                      ),
                      itemBuilder: (ctx, index, realIdx) {
                        return Stack(
                          children: [
                            // Shimmer Effect
                            Positioned.fill(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Image Network
                            Image.network(
                              widget.travelPackage.images![index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                                        radius: 15,
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
                                  ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.travelPackage.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Resale Banner
            if(widget.travelPackage.isResale==true)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Resale',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
