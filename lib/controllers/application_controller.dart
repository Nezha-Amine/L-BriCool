import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import 'auth_controller.dart';

class ApplicationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  Future<bool> applyForGig(String gigId) async {
    try {
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return false;

      bool alreadyApplied = await hasAppliedToGig(gigId);
      if (alreadyApplied) return false;

      final userDoc = await _firestore.collection('users').doc(studentId).get();
      String studentName = '';
      if (userDoc.exists) {
        studentName = userDoc.data()?['fullName'] ?? '';
      }

      final application = ApplicationModel(
        gigId: gigId,
        studentId: studentId,
        status: 'pending',
        appliedAt: Timestamp.now(),
        studentName: studentName,
      );

      await _firestore.collection('applications').add(application.toMap());
      return true;
    } catch (e) {
      print('Error applying for gig: $e');
      return false;
    }
  }




  // Check if the student has already applied for a gig
  Future<bool> hasAppliedToGig(String gigId) async {
    try {
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return false;

      QuerySnapshot applications = await _firestore
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      return applications.docs.isNotEmpty;
    } catch (e) {
      print('Error checking application status: $e');
      return false;
    }
  }

  // Get all applications for a specific gig
  Future<List<ApplicationModel>> getApplicationsForGig(String gigId) async {
    try {
      QuerySnapshot applicationDocs = await _firestore
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .orderBy('appliedAt', descending: true)
          .get();

      return applicationDocs.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting applications for gig: $e');
      return [];
    }
  }

  // Get all applications by current student
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return [];

      QuerySnapshot applicationDocs = await _firestore
          .collection('applications')
          .where('studentId', isEqualTo: studentId)
          .orderBy('appliedAt', descending: true)
          .get();

      return applicationDocs.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting my applications: $e');
      return [];
    }
  }

  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    try {
      DocumentSnapshot applicationDoc = await _firestore
          .collection('applications')
          .doc(applicationId)
          .get();

      if (!applicationDoc.exists) return false;

      String gigId = (applicationDoc.data() as Map<String, dynamic>)['gigId'];
      String studentId = (applicationDoc.data() as Map<String, dynamic>)['studentId'];

      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });

      if (status == 'accepted') {
        await _firestore.collection('gigs').doc(gigId).update({
          'status': 'active',
          'selectedStudentId': studentId,
        });

        // Get all pending applications for this gig
        QuerySnapshot otherApps = await _firestore
            .collection('applications')
            .where('gigId', isEqualTo: gigId)
            .where('status', isEqualTo: 'pending')
            .where(FieldPath.documentId, isNotEqualTo: applicationId)
            .get();

        // Reject all other applications
        WriteBatch batch = _firestore.batch();
        for (var doc in otherApps.docs) {
          batch.update(doc.reference, {
            'status': 'rejected',
            'updatedAt': Timestamp.now(),
          });
        }
        await batch.commit();

        return true;
      }

      return true;
    } catch (e) {
      print('Error updating application status: $e');
      return false;
    }
  }

  Future<bool> updateGigStatus(String gigId, String status) async {
    try {
      // Validate status
      if (!['active', 'completed', 'cancelled'].contains(status)) {
        return false;
      }

      // Update gig status
      await _firestore.collection('gigs').doc(gigId).update({
        'status': status,
      });

      if (status == 'completed' || status == 'cancelled') {
        QuerySnapshot acceptedApp = await _firestore
            .collection('applications')
            .where('gigId', isEqualTo: gigId)
            .where('status', isEqualTo: 'accepted')
            .limit(1)
            .get();

        if (acceptedApp.docs.isNotEmpty) {
          await _firestore
              .collection('applications')
              .doc(acceptedApp.docs.first.id)
              .update({
            'status': status,
            'updatedAt': Timestamp.now(),
          });
        }
      }

      return true;
    } catch (e) {
      print('Error updating gig status: $e');
      return false;
    }
  }

  Future<ApplicationModel?> getMyApplicationForGig(String gigId) async {
    try {
      final studentId = _authController.getCurrentUserId();
      if (studentId == null) return null;

      QuerySnapshot applications = await _firestore
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (applications.docs.isEmpty) return null;

      var appDoc = applications.docs.first;
      return ApplicationModel.fromMap(
        appDoc.data() as Map<String, dynamic>,
        appDoc.id,
      );
    } catch (e) {
      print('Error getting my application for gig: $e');
      return null;
    }
  }


  // In application_controller.dart, add this method

  Future<ApplicationModel?> getApplicationForGigAndStudent(String gigId, String studentId) async {
    try {
      QuerySnapshot applications = await _firestore
          .collection('applications')
          .where('gigId', isEqualTo: gigId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (applications.docs.isNotEmpty) {
        return ApplicationModel.fromMap(
            applications.docs.first.data() as Map<String, dynamic>,
            applications.docs.first.id
        );
      }
      return null;
    } catch (e) {
      print('Error getting application: $e');
      return null;
    }
  }
}