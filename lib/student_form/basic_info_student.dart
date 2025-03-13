import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtp;
import 'package:lbrikol/student_form/academic_info.dart';

// Note: The image_picker package doesn't work for me for
// reasons idk about them
// don't forget to execute in your terminal: flutter pub get image_picker
// and try to uncomment lines 3, 21, 23-31 and 69

class BasicInfoStudentPage extends StatefulWidget {
  const BasicInfoStudentPage({super.key});

  @override
  _BasicInfoStudentPageState createState() => _BasicInfoStudentPageState();
}

class _BasicInfoStudentPageState extends State<BasicInfoStudentPage> {
  File? _image;
  // final picker = ImagePicker();
  final TextEditingController _dateController = TextEditingController();

  // Future<void> _pickImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text("Basic Information", style: TextStyle(color: Colors.white)),
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
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                // onTap: _pickImage,
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
            _buildTextField("Full Name", "Full Name"),
            SizedBox(height: 15),
            _buildDateField("Birth Date", _dateController, _pickDate),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildDropdownField("Gender", ["Male", "Female"])),
                SizedBox(width: 10),
                Expanded(
                    child: _buildTextField("Age", "Enter age", isNumber: true)),
              ],
            ),
            SizedBox(height: 15),
            _buildTextField("Address", "Enter address",
                icon: Icons.location_on),
            SizedBox(height: 15),
            _buildTextField("Phone Number", "Phone number", isNumber: true),
            SizedBox(height: 30),
            Center(
              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcademicInformationScreen(),  // Correct target
                    ),
                  );
                },
                child: const Text("NEXT"),
                ),
              ),
            ],

        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {bool isNumber = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
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
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}
