import 'package:flutter/material.dart';
import 'package:lbrikol/student_form/skills_services.dart';

class AcademicInformationScreen extends StatelessWidget {
  const AcademicInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCurvedHeader("Academic Information", context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(decoration: _inputDecoration('Academic Information')),
                  const SizedBox(height: 15),
                  TextField(decoration: _inputDecoration('Field of Study')),
                  const SizedBox(height: 15),
                  TextField(decoration: _inputDecoration('Year of Study (e.g., 1st Year, 2nd Year)')),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SkillsAndServicesScreen()));
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
}

// Reusable styling functions
InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
  );
}

ButtonStyle _elevatedButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF40189C),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
  );
}

Widget _buildCurvedHeader(String title, BuildContext context) {
  return Stack(
    children: [
      Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Color(0xFF40189C),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
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
        child: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    ],
  );
}
