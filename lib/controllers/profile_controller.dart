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

  final String cloudName = "uyour_cloud_name";
  final String apiKey = "your_api_key";
  final String apiSecret = "your_secret_key";

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String signature = generateSignature(timestamp, apiSecret);

      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", url)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

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
  String generateSignature(int timestamp, String apiSecret, {String? folder}) {
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
      String? imageUrl;

      if (profileImage != null) {
        imageUrl = await uploadFileToCloudinary(profileImage, folder: "profile_images");
        if (imageUrl == null) {
          throw "Image upload to Cloudinary failed";
        }
      }

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw "User not authenticated";
      }

      Map<String, dynamic> userData = {
        "id": currentUser.uid,
        "email": currentUser.email,
        "fullName": fullName,
        "birthDate": birthDate,
        "gender": gender,
        "age": age,
        "address": address,
        "phoneNumber": phoneNumber,
        "profilePicture": imageUrl,
        "role": "client",
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("users").doc(currentUser.uid).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


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

      if (profileImage != null) {
        profileImageUrl = await uploadFileToCloudinary(profileImage, folder: "profile_images");
        if (profileImageUrl == null) throw "Profile image upload failed";
      }

      studentDocumentUrl = await uploadFileToCloudinary(studentDocument, folder: "student_documents");
      if (studentDocumentUrl == null) throw "Student document upload failed";

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw "User not authenticated";
      }

      List<String> services = [];
      if (selectedService != null && selectedService.isNotEmpty) {
        services.add(selectedService);
      }

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

      await _firestore.collection("users").doc(currentUser.uid).set(userData);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile saved successfully! Your account is pending approval."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}