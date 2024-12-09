import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/new_travel_package_details_page.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class TravelPackageCard extends StatefulWidget {
  final NewTravelPackageModel travelPackage;
  final String currentUserId;
  const TravelPackageCard(
      {super.key, required this.travelPackage, required this.currentUserId});

  @override
  _TravelPackageCardState createState() => _TravelPackageCardState();
}

class _TravelPackageCardState extends State<TravelPackageCard> {
  int _currentImageIndex = 0;
  FirestoreService _firestoreService = FirestoreService();
  UserModel? travelCompanyUser;
  bool userLoaded = false;
  bool save = false;

  @override
  void initState() {
    super.initState();
    fetchTravelCompany();
    addClickNum();
    addSaveNum();
  }

  void addSaveNum() async {
    Map<String, bool>? saveMap = widget.travelPackage.saveNum;
    if (saveMap != null) {
      if (saveMap.containsKey(widget.currentUserId)) {
        save = saveMap[widget.currentUserId]!;
      }
    }
  }

  void addClickNum() async {
    Map<String, bool>? clickNum = widget.travelPackage.clickNum;
    if (clickNum != null) {
      if (!clickNum.containsKey(widget.currentUserId)) {
        await _firestoreService.updateMapField('New_Travel_Packages',
            widget.travelPackage.id, 'view_num', widget.currentUserId, true);
      }
    } else {
      await _firestoreService.updateMapField('New_Travel_Packages',
          widget.travelPackage.id, 'view_num', widget.currentUserId, true);
    }
  }

  void fetchTravelCompany() async {
    Map<String, dynamic>? userMap;
    userMap = await _firestoreService.getDataById(
        'User', widget.travelPackage.createdBy);

    setState(() {
      if (userMap != null) {
        travelCompanyUser = UserModel.fromMap(userMap, userMap['id']);
        print(travelCompanyUser);
        if (travelCompanyUser != null) {
          userLoaded = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.travelPackage.isAvailable==true? 
    Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTravelPackageDetailsPage(
                travelPackage: widget.travelPackage,
                currentUserId: widget.currentUserId,
                travelPackageUser: travelCompanyUser!,
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
                              Row(
                                children: [
                                  Text(
                                      '${DateFormat('yyyy-MM-dd').format(widget.travelPackage.startDate)} - ${DateFormat('yyyy-MM-dd').format(widget.travelPackage.endDate)}'),
                                  Spacer(),
                                  Text(
                                    '${widget.travelPackage.price.toStringAsFixed(2)}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              travelCompanyUser != null
                                  ? Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundImage:
                                              NetworkImage(travelCompanyUser!.profilePic),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(travelCompanyUser!.username),
                                        Spacer(),
                                        save == true
                                            ? IconButton(
                                                onPressed: changeSave,
                                                icon: Icon(Icons
                                                    .bookmark,color: const Color.fromARGB(255, 159, 118,249),))
                                            : IconButton(
                                                onPressed: changeSave,
                                                icon: Icon(Icons
                                                    .bookmark_border_outlined,color: const Color.fromARGB(255, 159, 118,249),))
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
                      ],
                    ),
                  ),
                ],
              ),
              // Resale Banner
              if (widget.travelPackage.isResale == true)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
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
      ),
    ):SizedBox.shrink();
  }

  void changeSave() async {
    if (save == true) {
      await _firestoreService.updateMapField('New_Travel_Packages',
          widget.travelPackage.id, 'save_num', widget.currentUserId, false);
    } else {
      await _firestoreService.updateMapField('New_Travel_Packages',
          widget.travelPackage.id, 'save_num', widget.currentUserId, true);
    }
    setState(() {
      save = !save;
    });
  }
}
