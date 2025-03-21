import 'package:cloud_firestore/cloud_firestore.dart';

class GigModel {
  final String? id;
  final String category;
  final String description;
  final String address;
  final double hourlyRate;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isDateRange;
  final Map<String, int> startTime; // Store as hours and minutes
  final Map<String, int> endTime;
  final List<Map<String, String>> childrenDetails; // For babysitting
  final List<String> languages;
  final List<String> tasks;
  final String clientId;
  final String clientName;
  final Timestamp createdAt;
  final String status; // pending, active, completed, cancelled

  GigModel({
    this.id,
    required this.category,
    required this.description,
    required this.address,
    required this.hourlyRate,
    required this.startDate,
    this.endDate,
    required this.isDateRange,
    required this.startTime,
    required this.endTime,
    required this.childrenDetails,
    required this.languages,
    required this.tasks,
    required this.clientId,
    required this.clientName,
    required this.createdAt,
    this.status = 'active',

  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'address': address,
      'hourlyRate': hourlyRate,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isDateRange': isDateRange,
      'startTime': startTime,
      'endTime': endTime,
      'childrenDetails': childrenDetails,
      'languages': languages,
      'tasks': tasks,
      'clientId': clientId,
      'clientName': clientName,
      'createdAt': createdAt,
      'status': status,
    };
  }

  // Create GigModel from Firestore data
  factory GigModel.fromMap(Map<String, dynamic> map, String id) {
    return GigModel(
      id: id,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isDateRange: map['isDateRange'] ?? false,
      startTime: Map<String, int>.from(map['startTime'] ?? {'hour': 0, 'minute': 0}),
      endTime: Map<String, int>.from(map['endTime'] ?? {'hour': 0, 'minute': 0}),
      childrenDetails: List<Map<String, String>>.from(
        (map['childrenDetails'] ?? []).map((x) => Map<String, String>.from(x)),
      ),
      languages: List<String>.from(map['languages'] ?? []),
      tasks: List<String>.from(map['tasks'] ?? []),
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      status: map['status'] ?? 'active',
    );
  }

  // Create a copy with modified fields
  GigModel copyWith({
    String? id,
    String? category,
    String? description,
    String? address,
    double? hourlyRate,
    DateTime? startDate,
    DateTime? endDate,
    bool? isDateRange,
    Map<String, int>? startTime,
    Map<String, int>? endTime,
    List<Map<String, String>>? childrenDetails,
    List<String>? languages,
    List<String>? tasks,
    String? clientId,
    String? clientName,
    Timestamp? createdAt,
    String? status,
  }) {
    return GigModel(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isDateRange: isDateRange ?? this.isDateRange,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      childrenDetails: childrenDetails ?? this.childrenDetails,
      languages: languages ?? this.languages,
      tasks: tasks ?? this.tasks,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}