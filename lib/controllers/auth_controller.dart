import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // **Sign Up**
  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      UserModel newUser = UserModel(
        id: userId,
        fullName: '',
        email: email,
        birthDate: '',
        gender: '',
        age: 0,
        address: '',
        phoneNumber: '',
        role: null,
        isApproved: null,
      );

      await _firestore.collection('users').doc(userId).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
    } catch (e) {
      print("Error signing up: $e");
    }
    return null;
  }
// Add this method to AuthController class in auth_controller.dart
// Add this to AuthController class
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  Future<UserModel?> getCurrentUser() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        print("User data: $userData");

        // Make sure to return the UserModel
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

// Add to AuthController class
  Stream<UserModel?> getCurrentUserStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore.collection('users').doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.exists
        ? UserModel.fromMap(snapshot.data() as Map<String, dynamic>)
        : null);
  }
  // **Logout**
  Future<void> logout() async {
    await _auth.signOut();
  }
}
