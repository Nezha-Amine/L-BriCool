import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lbricool/pages/student_form/skills_services.dart';

import '../student_interfaces/home_page_gigs.dart';
// import 'package:lbrikol/student_form/skills_services_student.dart';

// Screen for collecting academic information from students.
class AcademicInformationScreen extends StatefulWidget {
  final String fullName;
  final String birthDate;
  final String gender;
  final int age;
  final String address;
  final String phoneNumber;
  final File? profileImage;

  const AcademicInformationScreen({
    super.key,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.age,
    required this.address,
    required this.phoneNumber,
    this.profileImage,
  });

  @override
  State<AcademicInformationScreen> createState() =>
      _AcademicInformationScreenState();
}


class _AcademicInformationScreenState extends State<AcademicInformationScreen> {
  // Controllers for text fields
  final TextEditingController _academicInfoController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _yearOfStudyController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _academicInfoController.dispose();
    _fieldOfStudyController.dispose();
    _yearOfStudyController.dispose();
    super.dispose();
  }

  // Validates input fields before proceeding to the next page.
  // fields should not be empty
  void _validateAndProceed() {
    if (_academicInfoController.text.isEmpty ||
        _fieldOfStudyController.text.isEmpty ||
        _yearOfStudyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the fields"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkillsAndServicesScreen(
            fullName: widget.fullName,
            birthDate: widget.birthDate,
            gender: widget.gender,
            age: widget.age,
            address: widget.address,
            phoneNumber: widget.phoneNumber,
            profileImage: widget.profileImage,
            university: _academicInfoController.text,
            fieldOfStudy: _fieldOfStudyController.text,
            yearOfStudy: _yearOfStudyController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text(
          "Academic Information",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Academic Information',
                style: GoogleFonts.rockSalt(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF40189D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            _buildTextField("Academic Information", "Enter academic details",
                _academicInfoController),
            const SizedBox(height: 30),
            _buildTextField("Field of Study", "Enter your field of study",
                _fieldOfStudyController),
            const SizedBox(height: 30),
            _buildTextField("Year of Study", "e.g., 1st Year, 2nd Year",
                _yearOfStudyController),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40189D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _validateAndProceed,
                child: const Text(
                  "NEXT",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a text field with optional number input and an icon.
  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ],
    );
  }
}
