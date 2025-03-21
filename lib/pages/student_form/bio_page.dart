import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lbricool/pages/student_form/profile_verification_page.dart';
import '../../controllers/profile_controller.dart';

class BioPage extends StatefulWidget {
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
  final List<String> skills;
  final String? selectedService;

  const BioPage({
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
    required this.skills,
    this.selectedService,
  });

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  final TextEditingController _bioController = TextEditingController();
  final ProfileController _profileController = ProfileController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(_checkButtonState);
  }

  void _checkButtonState() {
    setState(() {
      _isButtonEnabled = _bioController.text.length >= 100;
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Purple header
            Container(
              color: const Color(0xFF40189D),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: const Text(
                      'Bio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Write a bio to tell the world about yourself .',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Help people get to know you at a glance. Tell them clearly, using paragraphs or bullet points .you can always edit later !',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        controller: _bioController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Describe your top skills, experiences, and interests. This is one of the first things clients will see on your profile.',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'At least 100 characters',
                      style: TextStyle(
                        color: _isButtonEnabled ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileVerificationPage(
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
                                skills: widget.skills,
                                selectedService: widget.selectedService,
                                bio: _bioController.text,
                              ),
                            ),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF40189D),
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}