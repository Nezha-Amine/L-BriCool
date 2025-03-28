import 'dart:io';

import 'package:flutter/material.dart';

import 'bio_page.dart';

class SkillsAndServicesScreen extends StatefulWidget {
  final String fullName;
  final String birthDate;
  final String gender;
  final int age;
  final String address;
  final String phoneNumber;
  final File? profileImage;
  final String university;
  final String fieldOfStudy;
  final String yearOfStudy;

  const SkillsAndServicesScreen({
    super.key,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.age,
    required this.address,
    required this.phoneNumber,
    this.profileImage,
    required this.university,
    required this.fieldOfStudy,
    required this.yearOfStudy,
  });

  @override
  SkillsAndServicesScreenState createState() => SkillsAndServicesScreenState();
}


class SkillsAndServicesScreenState extends State<SkillsAndServicesScreen> {
  String? selectedService;
  List<String> services = ['Tutoring', 'Babysitting', 'Dog Walking'];
  Map<String, bool> selectedSkills = {};

  @override
  void initState() {
    super.initState();
    selectedSkills = {
      'Reliable & Punctual': false,
      'Calm & Polite': false,
      'Good Communication': false,
      'Animal Lover': false,
      'Attention to Detail': false,
      'Adaptability & Flexibility': false,
      'Conflict Resolution Skills': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          _buildCurvedHeader("What Can You Offer?", context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Services You Can Provide'),
                    hint: const Text('Select Services You Can Provide'),
                    value: selectedService,
                    items: services.map((service) {
                      return DropdownMenuItem(value: service, child: Text(service));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: selectedSkills.keys.map((skill) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSkills[skill] = !selectedSkills[skill]!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: selectedSkills[skill]! ? const Color(0xFF40189C) : Colors.white,
                            border: Border.all(color: const Color(0xFF40189C)),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              color: selectedSkills[skill]! ? Colors.white : const Color(0xFF40189C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      // Get selected skills as a list
                      List<String> skills = selectedSkills.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BioPage(
                            fullName: widget.fullName,
                            birthDate: widget.birthDate,
                            gender: widget.gender,
                            age: widget.age,
                            address: widget.address,
                            phoneNumber: widget.phoneNumber,
                            profileImage: widget.profileImage,
                            university: widget.university,
                            fieldOfStudy: widget.fieldOfStudy,
                            yearOfStudy: widget.yearOfStudy,
                            skills: skills,
                            selectedService: selectedService,
                          ),
                        ),
                      );
                    },
                    style: _elevatedButtonStyle(),
                    child: const Text('NEXT'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedHeader(String title, BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF40189C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 60,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            child: Text(title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF40189C),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

