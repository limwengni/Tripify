import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

final List<String> imageUrls = [
  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg',
  // Add more image URLs as needed
];

class TravelPackageCard extends StatelessWidget {
  const TravelPackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Same corner radius as the Card
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
              width: double.infinity, // Ensures the container takes the full width
              child: CarouselSlider.builder(
                itemCount: imageUrls.length, // Use the length of image URLs
                options: CarouselOptions(
                  viewportFraction: 1,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                ),
                itemBuilder: (ctx, index, realIdx) {
                  return Image.network(
                    imageUrls[index],
                    width: double.infinity, // Make sure the image takes full width
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
                        '3D2N Penang Trip',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text('18 Jan 2025 - 20 Jan 2025'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15, // Adjust the radius as needed
                            backgroundImage: const NetworkImage(
                              'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg',
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(width: 10),
                          const Text('From Savy Travel Company'),
                        ],
                      ),
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
    );
  }
}
