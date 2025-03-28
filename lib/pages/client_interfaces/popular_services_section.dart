import 'package:flutter/material.dart';

class ServiceItem {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  ServiceItem({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });
}

class PopularServicesSection extends StatelessWidget {
  const PopularServicesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ServiceItem> services = [
      ServiceItem(
        title: 'Tutoring',
        imagePath: 'assets/images/tutoring.png',
        onTap: () {
        },
      ),
      ServiceItem(
        title: 'Babysitting',
        imagePath: 'assets/images/babysitting.png',
        onTap: () {
        },
      ),
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                // Service image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    services[index].imagePath,
                    height: 150,
                    width: 170,
                    fit: BoxFit.cover,
                  ),
                ),

                // Service title at the bottom
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    services[index].title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),

                // Clickable layer
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: services[index].onTap,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}