import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String cloudName = "dlers4po2";
  final String apiKey = "926487664528451";
  final String apiSecret = "wlSr9HCnlghrXzMWPl2n1wCUpME"; // Store securely, never expose in client code

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      // Generate timestamp and signature
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String signature = generateSignature(timestamp, apiSecret);

      // Create the request URL
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      // Create multipart request with authentication
      var request = http.MultipartRequest("POST", url)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Send request and process response
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = jsonDecode(await response.stream.bytesToString());
        return responseData["secure_url"];
      } else {
        print("Cloudinary upload failed with status: ${response.statusCode}");
        print("Response: ${await response.stream.bytesToString()}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  // Upload any file to Cloudinary (can be used for both images and documents)
  Future<String?> uploadFileToCloudinary(File file, {String folder = "uploads"}) async {
    try {
      // Generate timestamp and signature
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// In uploadFileToCloudinary method
      String signature = generateSignature(timestamp, apiSecret, folder: folder);
      // Create the request URL
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/auto/upload");

      // Create multipart request with authentication
      var request = http.MultipartRequest("POST", url)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request and process response
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = jsonDecode(await response.stream.bytesToString());
        return responseData["secure_url"];
      } else {
        print("Cloudinary upload failed with status: ${response.statusCode}");
        print("Response: ${await response.stream.bytesToString()}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  // Generate signature for Cloudinary authentication
// Generate signature for Cloudinary authentication
  String generateSignature(int timestamp, String apiSecret, {String? folder}) {
    // Create signature string with all parameters
    String signatureString = "";

    if (folder != null) {
      signatureString += "folder=$folder&";
    }

    signatureString += "timestamp=$timestamp$apiSecret";

    // Generate SHA-1 hash of the signature string
    var bytes = utf8.encode(signatureString);
    var digest = sha1.convert(bytes);

    return digest.toString();
  }

  // Function to Save Client Information
  Future<void> saveClientInfo({
    required String fullName,
    required String birthDate,
    required String gender,
    required int age,
    required String address,
    required String phoneNumber,
    required File? profileImage,
    required BuildContext context,
  }) async {
    try {
      // Show loading indicator
      String? imageUrl;

      // Upload image to Cloudinary if provided
      if (profileImage != null) {
        // Show upload indicator or message if needed
        imageUrl = await uploadFileToCloudinary(profileImage, folder: "profile_images");
        if (imageUrl == null) {
          throw "Image upload to Cloudinary failed";
        }
      }

      // Get current user ID
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw "User not authenticated";
      }

      // Create user data map
      Map<String, dynamic> userData = {
        "id": currentUser.uid,
        "email": currentUser.email,
        "fullName": fullName,
        "birthDate": birthDate,
        "gender": gender,
        "age": age,
        "address": address,
        "phoneNumber": phoneNumber,
        "profilePicture": imageUrl, // Store Cloudinary image URL
        "role": "client",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection("users").doc(currentUser.uid).set(userData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home or dashboard page
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Updated function to save student information with document upload
  // Add this method to your ProfileController class
  Future<void> saveStudentInfo({
    required String fullName,
    required String birthDate,
    required String gender,
    required int age,
    required String address,
    required String phoneNumber,
    required String university,
    required String fieldOfStudy,
    required String yearOfStudy,
    required File? profileImage,
    required File? studentDocument,
    required String? bio,
    required List<String>? skills,
    String? selectedService,
    required BuildContext context,
  }) async {
    if (fullName.isEmpty ||
        birthDate.isEmpty ||
        gender.isEmpty ||
        university.isEmpty ||
        fieldOfStudy.isEmpty ||
        yearOfStudy.isEmpty ||
        address.isEmpty ||
        phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if student document is provided
    if (studentDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your student document"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String? profileImageUrl;
      String? studentDocumentUrl;

      // Upload profile image if provided
      if (profileImage != null) {
        profileImageUrl = await uploadFileToCloudinary(profileImage, folder: "profile_images");
        if (profileImageUrl == null) throw "Profile image upload failed";
      }

      // Upload student document
      studentDocumentUrl = await uploadFileToCloudinary(studentDocument, folder: "student_documents");
      if (studentDocumentUrl == null) throw "Student document upload failed";

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw "User not authenticated";
      }

      // Create services list if a service was selected
      List<String> services = [];
      if (selectedService != null && selectedService.isNotEmpty) {
        services.add(selectedService);
      }

      // Create user data map with all the required and optional fields
      Map<String, dynamic> userData = {
        "id": currentUser.uid,
        "email": currentUser.email,
        "fullName": fullName,
        "birthDate": birthDate,
        "gender": gender,
        "age": age,
        "address": address,
        "phoneNumber": phoneNumber,
        "universityName": university,
        "fieldOfStudy": fieldOfStudy,
        "yearOfStudy": int.tryParse(yearOfStudy) ?? 1,
        "profilePicture": profileImageUrl,
        "studentDocument": studentDocumentUrl,
        "bio": bio,
        "skills": skills,
        "services": services,
        "role": "student",
        "isApproved": false,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection("users").doc(currentUser.uid).set(userData);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile saved successfully! Your account is pending approval."),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home or dashboard page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}