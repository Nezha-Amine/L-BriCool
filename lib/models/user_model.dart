import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, client, admin }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String birthDate;
  final String gender;
  final int age;
  final String address;
  final String phoneNumber;
  final UserRole? role;
  final String? profilePicture;

  // Student-specific fields
  final String? universityName;
  final String? fieldOfStudy;
  final int? yearOfStudy;
  final List<String>? services;
  final Map<String, dynamic>? serviceDetails;
  final List<String>? skills;
  final String? bio;
  final String? studentDocument;
  final bool? isApproved;
  final Timestamp? createdAt;

  // Constructor
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.age,
    required this.address,
    required this.phoneNumber,
    required this.role,
    this.profilePicture,
    this.universityName,
    this.fieldOfStudy,
    this.yearOfStudy,
    this.services,
    this.serviceDetails,
    this.skills,
    this.bio,
    this.studentDocument,
    this.isApproved,
    this.createdAt,
  });

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'birthDate': birthDate,
      'gender': gender,
      'age': age,
      'address': address,
      'phoneNumber': phoneNumber,
      'role': role?.toString().split('.').last,
      'universityName': universityName,
      'fieldOfStudy': fieldOfStudy,
      'yearOfStudy': yearOfStudy,
      'services': services,
      'serviceDetails': serviceDetails,
      'skills': skills,
      'bio': bio,
      'studentDocument': studentDocument,
      'isApproved': isApproved,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Factory constructor to create a UserModel from a Map (from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Parse role
    UserRole parseRole(String roleStr) {
      switch (roleStr.toLowerCase()) {
        case 'client':
          return UserRole.client;
        case 'student':
          return UserRole.student;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.client; // Default fallback
      }
    }

    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      birthDate: map['birthDate'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] != null ? parseRole(map['role']) : null, // Handle null role
      profilePicture: map['profilePicture'],
      universityName: map['universityName'],
      fieldOfStudy: map['fieldOfStudy'],
      yearOfStudy: map['yearOfStudy'],
      services: map['services'] != null ? List<String>.from(map['services']) : null,
      serviceDetails: map['serviceDetails'],
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      bio: map['bio'],
      studentDocument: map['studentDocument'],
      isApproved: map['isApproved'],
      createdAt: map['createdAt'],
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? birthDate,
    String? gender,
    int? age,
    String? address,
    String? phoneNumber,
    UserRole? role,
    String? profilePicture,
    String? universityName,
    String? fieldOfStudy,
    int? yearOfStudy,
    List<String>? services,
    Map<String, dynamic>? serviceDetails,
    List<String>? skills,
    String? bio,
    String? studentDocument,
    bool? isApproved,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      universityName: universityName ?? this.universityName,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      services: services ?? this.services,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      studentDocument: studentDocument ?? this.studentDocument,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}