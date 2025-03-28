import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dtp;

import '../../controllers/profile_controller.dart';

class BasicInfoClientPage extends StatefulWidget {
  const BasicInfoClientPage({super.key});

  @override
  _BasicInfoClientPageState createState() => _BasicInfoClientPageState();
}

class _BasicInfoClientPageState extends State<BasicInfoClientPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _image;
  final picker = ImagePicker();
  String _selectedGender = "Male";
  bool _isLoading = false;

  final ProfileController _profileController = ProfileController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Method to pick date
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

  void _saveClientInfo() async {
    // Validate form fields
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    int? age = int.tryParse(_ageController.text);
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid age")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _profileController.saveClientInfo(
      fullName: _nameController.text,
      birthDate: _dateController.text,
      gender: _selectedGender,
      age: age,
      address: _addressController.text,
      phoneNumber: _phoneController.text,
      profileImage: _image,
      context: context,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        backgroundColor: Color(0xFF40189D),
        title: Text("Basic Information", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF40189D)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple[100],
                  child: _image == null
                      ? Icon(Icons.camera_alt, color: Colors.purple, size: 30)
                      : ClipOval(
                      child: Image.file(_image!,
                          fit: BoxFit.cover, width: 80, height: 80)),
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildTextField(
                "Full Name",
                "Full Name",
                controller: _nameController
            ),
            SizedBox(height: 15),
            _buildDateField("Birth Date", _dateController, _pickDate),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildDropdownField("Gender", ["Male", "Female"])),
                SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        "Age",
                        "Enter age",
                        isNumber: true,
                        controller: _ageController
                    )),
              ],
            ),
            SizedBox(height: 15),
            _buildTextField(
                "Address",
                "Enter address",
                icon: Icons.location_on,
                controller: _addressController
            ),
            SizedBox(height: 15),
            _buildTextField(
                "Phone Number",
                "Phone number",
                isNumber: true,
                controller: _phoneController
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF40189D),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _saveClientInfo,
                child: const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool isNumber = false, IconData? icon, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: "Add your birthday",
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: SizedBox(),
            hint: Text("Select"),
            value: _selectedGender,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  _selectedGender = value;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}