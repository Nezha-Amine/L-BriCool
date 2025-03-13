import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screen for selecting skills and services
class SkillsServicesScreen extends StatefulWidget {
  const SkillsServicesScreen({super.key});

  @override
  SkillsServicesScreenState createState() => SkillsServicesScreenState();
}

class SkillsServicesScreenState extends State<SkillsServicesScreen> {
  // Variable to store the selected service
  String? selectedService;

  // List of available services (to be changed if needed)
  List<String> services = ['Tutoring', 'Babysitting', 'Dog Walking'];

  // Map to track selected skills
  // this will be added to database as a list
  Map<String, bool> selectedSkills = {};

  @override
  void initState() {
    super.initState();

    // Initializing skills with a default value of false (not selected)
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text(
          "Skills & Services",
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

            // Page title styled with Google Fonts
            Center(
              child: Text(
                'Your service and skills',
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

            // Dropdown for selecting a service
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Select a service you can provide'),
              hint: const Text('Select your service'),
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
            const SizedBox(height: 30),

            // Skills selection section
            const Text('Select your skills:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedSkills[skill]!
                          ? const Color(0xFF40189D)
                          : Colors.white,
                      border: Border.all(color: const Color(0xFF40189D)),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: selectedSkills[skill]!
                            ? Colors.white
                            : const Color(0xFF40189D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Next button to proceed to the next screen
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40189D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // TODO: Implement navigation to next screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const MainScreen()),
                  // );
                },
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

  // Method for styling input fields
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
