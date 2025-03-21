import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lbricool/pages/student_form/success_dialogue.dart';
import 'package:lbricool/pages/student_interfaces/home_page_gigs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lbricool/controllers/profile_controller.dart';

import '../auth/login.dart';

class ProfileVerificationPage extends StatefulWidget {
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
  final String bio;

  const ProfileVerificationPage({
    Key? key,
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
    required this.bio,
  }) : super(key: key);

  @override
  State<ProfileVerificationPage> createState() => _ProfileVerificationPageState();
}

class _ProfileVerificationPageState extends State<ProfileVerificationPage> {
  bool _documentUploaded = false;
  bool _isSubmitting = false;
  bool _showSuccessDialog = false;
  File? _documentFile;
  String _documentName = "";
  final ProfileController _profileController = ProfileController();

  Future<void> _uploadDocument() async {
    // Show a dialog to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: const Text('Choose Document'),
                onTap: () {
                  Navigator.pop(context);
                  _getDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _documentFile = File(image.path);
          _documentName = image.name;
          _documentUploaded = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e')),
      );
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _documentFile = File(image.path);
          _documentName = image.name;
          _documentUploaded = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: $e')),
      );
    }
  }

  Future<void> _getDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _documentFile = File(result.files.single.path!);
          _documentName = result.files.single.name;
          _documentUploaded = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting document: $e')),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (!_documentUploaded || _documentFile == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Use the ProfileController to save all student information
      await _profileController.saveStudentInfo(
        fullName: widget.fullName,
        birthDate: widget.birthDate,
        gender: widget.gender,
        age: widget.age,
        address: widget.address,
        phoneNumber: widget.phoneNumber,
        university: widget.university,
        fieldOfStudy: widget.fieldOfStudy,
        yearOfStudy: widget.yearOfStudy,
        profileImage: widget.profileImage,
        studentDocument: _documentFile,
        bio: widget.bio,
        skills: widget.skills,
        selectedService: widget.selectedService,
        context: context,
      );

      setState(() {
        _isSubmitting = false;
        _showSuccessDialog = true;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    }
  }

  void _dismissSuccessDialog() {
    setState(() {
      _showSuccessDialog = false;
    });

    // Navigate to the Login Page instead of HomePageGigs
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>  LogInPage()), // Replace with your actual login page widget
          (route) => false, // Remove all previous routes
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
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
                          'Profile Verification',
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
                          'Get Verified',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ensure a secure and trustworthy experience by verifying your profile.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _uploadDocument,
                          icon: const Icon(Icons.add),
                          label: const Text('Upload a Valid Student Proof'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Upload a photo of your student ID, school enrollment certificate, or any official document that verifies you are a student.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        if (_documentUploaded && _documentFile != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                _getFileTypeIcon(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _documentName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'Document uploaded successfully',
                                        style: TextStyle(color: Colors.green, fontSize: 12),
                                      ),
                                    ],
                                  ),

                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _documentUploaded = false;
                                      _documentFile = null;
                                      _documentName = "";
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                            onPressed: _documentUploaded && !_isSubmitting
                                ? _submitVerification
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF40189D),
                              disabledBackgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'SUBMIT',
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

          // Import and use Success Dialog component
          if (_showSuccessDialog)
            SuccessDialog(
              message: 'Your application has been submitted successfully! Our team is reviewing your student verification, and you\'ll receive a confirmation message once approved. Stay tuned and get ready for your first gig! 🎉',
              onOkPressed: _dismissSuccessDialog,
            ),
        ],
      ),
    );
  }

  Widget _getFileTypeIcon() {
    if (_documentFile == null) return const Icon(Icons.file_present);

    final String path = _documentFile!.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return const Icon(Icons.description, color: Colors.blue);
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
      return const Icon(Icons.image, color: Colors.green);
    }
    return const Icon(Icons.file_present);
  }
}