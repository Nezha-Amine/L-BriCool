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
      return await _authController.getCurrentUser();
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  // Create a new gig
  Future<bool> createGig(GigModel gig) async {
    try {
      final gigWithPendingStatus = gig.copyWith(status: 'pending');
      await _firestore.collection('gigs').add(gigWithPendingStatus.toMap());
      return true;
    } catch (e) {
      print('Error creating gig: $e');
      return false;
    }
  }

  Future<List<GigModel>> getMyGigs() async {
    try {
      final user = await _authController.getCurrentUser();
      if (user == null) return [];

      String userId = user.id;

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
  Future<bool> updateGigStatus(String gigId, String status) async {
    try {
      if (!['pending', 'active', 'completed', 'cancelled'].contains(status)) {
        return false;
      }

      await _firestore.collection('gigs').doc(gigId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating gig status: $e');
      return false;
    }
  }

  Future<bool> deleteGig(String gigId) async {
    try {
      await _firestore.collection('gigs').doc(gigId).delete();
      return true;
    } catch (e) {
      print('Error deleting gig: $e');
      return false;
    }
  }

  Future<List<GigModel>> getBrowseableGigs({String? category}) async {
    try {
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return [];

      QuerySnapshot applications = await _firestore
          .collection('applications')
          .where('studentId', isEqualTo: studentId)
          .get();

      Set<String> appliedGigIds = applications.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['gigId'] as String)
          .toSet();

      Query query = _firestore
          .collection('gigs')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true);

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      QuerySnapshot gigDocs = await query.get();

      List<GigModel> browseableGigs = gigDocs.docs
          .map((doc) => GigModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((gig) => !appliedGigIds.contains(gig.id))
          .toList();

      return browseableGigs;
    } catch (e) {
      print('Error getting browseable gigs: $e');
      return [];
    }
  }

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

  Map<String, int> timeOfDayToMap(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  TimeOfDay mapToTimeOfDay(Map<String, int> timeMap) {
    return TimeOfDay(
      hour: timeMap['hour'] ?? 0,
      minute: timeMap['minute'] ?? 0,
    );
  }

  Future<List<GigModel>> getStudentGigs() async {
    try {
      final user = await _authController.getCurrentUser();
      if (user == null) return [];

      String studentId = user.id;

      QuerySnapshot gigDocs = await _firestore
          .collection('gigs')
          .where('selectedStudentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return gigDocs.docs
          .map((doc) => GigModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting student gigs: $e');
      return [];
    }
  }
}