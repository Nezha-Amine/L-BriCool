import 'package:flutter/material.dart';

class BrowseGigsScreen extends StatelessWidget {
  const BrowseGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Search bar
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text(
          'Browse Gigs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search gigs here...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
