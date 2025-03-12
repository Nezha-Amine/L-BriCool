import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtp;
import 'package:google_fonts/google_fonts.dart';
import 'academic_info_student.dart';

// Quick note: The image_picker package doesn't work for me for
// reasons idk about them
// don't forget to execute in your terminal: flutter pub get image_picker
// and try to uncomment lines 3, 24, 34-42 and 131

// Page for collecting basic information from students.
class BasicInfoStudentPage extends StatefulWidget {
  const BasicInfoStudentPage({super.key});

  @override
  _BasicInfoStudentPageState createState() => _BasicInfoStudentPageState();
}

class _BasicInfoStudentPageState extends State<BasicInfoStudentPage> {
  File? _image;
  // final ImagePicker _picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender;

  // Function to pick an image from the gallery.
  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  // Function to pick a birth date using a date picker.
  void _pickDate() {
    dtp.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900, 1, 1),
      maxTime: DateTime(DateTime.now().year, 12, 31),
      onConfirm: (date) {
        setState(() {
          _dateController.text = "${date.day}/${date.month}/${date.year}";
        });
      },
      currentTime: DateTime.now(),
      locale: dtp.LocaleType.en,
    );
  }

  // Validates input fields before proceeding to the next page.
  // fields should not be empty
  void _validateAndProceed() {
    if (_fullNameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedGender == null ||
        _ageController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
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
            builder: (context) => const AcademicInformationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text("Basic Information",
            style: TextStyle(color: Colors.white)),
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
                'Tell us about yourself',
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

            // Profile Picture Upload Section
            Center(
              child: GestureDetector(
                // onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple[100],
                  child: _image == null
                      ? const Icon(Icons.camera_alt,
                          color: Colors.purple, size: 30)
                      : ClipOval(
                          child: Image.file(_image!,
                              fit: BoxFit.cover, width: 80, height: 80)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField("Full Name", "Enter full name",
                controller: _fullNameController),
            const SizedBox(height: 15),

            _buildDateField("Birth Date", _dateController, _pickDate),
            const SizedBox(height: 15),

            /// Gender and Age Fields
            Row(
              children: [
                Expanded(
                    child: _buildDropdownField("Gender", ["Male", "Female"],
                        (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                })),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField("Age", "Enter age",
                        controller: _ageController, isNumber: true)),
              ],
            ),
            const SizedBox(height: 15),

            _buildTextField("Address", "Enter address",
                controller: _addressController, icon: Icons.location_on),
            const SizedBox(height: 15),

            _buildTextField("Phone Number", "Enter phone number",
                controller: _phoneController, isNumber: true),
            const SizedBox(height: 30),

            /// Next Button
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
  Widget _buildTextField(String label, String hint,
      {bool isNumber = false,
      IconData? icon,
      TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ],
    );
  }

  /// Builds a date picker field.
  Widget _buildDateField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: "Add your birthday",
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ],
    );
  }

  /// Builds a dropdown field.
  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedGender,
          hint: const Text("Select"),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
