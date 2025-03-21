// application_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String? id;
  final String gigId;
  final String studentId;
  final String status; // 'pending', 'accepted', 'rejected'
  final Timestamp appliedAt;
  final Timestamp? updatedAt;
  final String? studentName; // Optional: for easier display

  ApplicationModel({
    this.id,
    required this.gigId,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.studentName,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'gigId': gigId,
      'studentId': studentId,
      'status': status,
      'appliedAt': appliedAt,
      'updatedAt': updatedAt,
      'studentName': studentName,
    };
  }

  // Create ApplicationModel from Firestore data
  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      gigId: map['gigId'] ?? '',
      studentId: map['studentId'] ?? '',
      status: map['status'] ?? 'pending',
      appliedAt: map['appliedAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
      studentName: map['studentName'],
    );
  }

  // Create a copy with modified fields
  ApplicationModel copyWith({
    String? id,
    String? gigId,
    String? studentId,
    String? status,
    Timestamp? appliedAt,
    Timestamp? updatedAt,
    String? studentName,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      gigId: gigId ?? this.gigId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
    );
  }
}