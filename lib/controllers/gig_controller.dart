import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/gig_model.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

class GigController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();


  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authController.getCurrentUser(); // Use getCurrentUser method
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  // Create a new gig
  Future<bool> createGig(GigModel gig) async {
    try {
      await _firestore.collection('gigs').add(gig.toMap());
      return true;
    } catch (e) {
      print('Error creating gig: $e');
      return false;
    }
  }

  // Get all gigs by current user
  Future<List<GigModel>> getMyGigs() async {
    try {
      final user = await _authController.getCurrentUser(); // This returns UserModel?
      if (user == null) return [];

      String userId = user.id; // Extract the ID from the user model

      QuerySnapshot gigDocs = await _firestore
          .collection('gigs')
          .where('clientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return gigDocs.docs
          .map((doc) => GigModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting my gigs: $e');
      return [];
    }
  }
  // Update gig status
  Future<bool> updateGigStatus(String gigId, String status) async {
    try {
      await _firestore.collection('gigs').doc(gigId).update({'status': status});
      return true;
    } catch (e) {
      print('Error updating gig status: $e');
      return false;
    }
  }

  // Delete a gig
  Future<bool> deleteGig(String gigId) async {
    try {
      await _firestore.collection('gigs').doc(gigId).delete();
      return true;
    } catch (e) {
      print('Error deleting gig: $e');
      return false;
    }
  }

  // Get gigs that can be browsed by students (excluding ones they've already applied to)
  Future<List<GigModel>> getBrowseableGigs({String? category}) async {
    try {
      Query query = _firestore
          .collection('gigs')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);

      // Apply category filter if provided
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot gigDocs = await query.get();
      List<GigModel> allGigs = gigDocs.docs
          .map((doc) => GigModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Get the current user ID
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return allGigs;

      // Get all gig IDs that the student has applied for
      QuerySnapshot applications = await _firestore
          .collection('applications')
          .where('studentId', isEqualTo: studentId)
          .get();

      Set<String> appliedGigIds = applications.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['gigId'] as String)
          .toSet();

      // Filter out gigs that the student has already applied for
      return allGigs.where((gig) => !appliedGigIds.contains(gig.id)).toList();
    } catch (e) {
      print('Error getting browseable gigs: $e');
      return [];
    }
  }

// Get a specific gig by ID
  Future<GigModel?> getGigById(String gigId) async {
    try {
      DocumentSnapshot gigDoc = await _firestore.collection('gigs').doc(gigId).get();

      if (gigDoc.exists) {
        return GigModel.fromMap(gigDoc.data() as Map<String, dynamic>, gigDoc.id);
      }
      return null;
    } catch (e) {
      print('Error getting gig by ID: $e');
      return null;
    }
  }

  // Convert TimeOfDay to map for storage
  Map<String, int> timeOfDayToMap(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  // Convert map to TimeOfDay for display
  TimeOfDay mapToTimeOfDay(Map<String, int> timeMap) {
    return TimeOfDay(
      hour: timeMap['hour'] ?? 0,
      minute: timeMap['minute'] ?? 0,
    );
  }
}