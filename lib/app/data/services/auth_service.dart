import 'package:city_guide_app/app/data/models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final Rx<UserRole> currentRole = UserRole.user.obs;

  void setRole(UserRole role) {
    currentRole.value = role;
  }

  Future<UserRole> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user?.uid ?? '';
      if (uid.isEmpty) {
        throw Exception('Unable to sign in.');
      }

      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firebaseFirestore.collection('users').doc(uid).get();

      final String roleRaw = snapshot.data()?['role']?.toString() ?? UserRole.user.name;
      final UserRole role = roleRaw == UserRole.admin.name
          ? UserRole.admin
          : UserRole.user;
      currentRole.value = role;
      return role;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e.code, isLogin: true));
    } on FirebaseException {
      throw Exception('Unable to fetch user profile. Please try again.');
    }
  }

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user?.uid ?? '';
      if (uid.isEmpty) {
        throw Exception('Unable to create account.');
      }

      await _firebaseFirestore.collection('users').doc(uid).set(
        <String, dynamic>{
          'fullName': fullName,
          'email': email,
          'role': UserRole.user.name,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      currentRole.value = UserRole.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e.code));
    } on FirebaseException {
      throw Exception('Failed to save user profile. Please try again.');
    }
  }

  String _mapFirebaseAuthError(String code, {bool isLogin = false}) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return isLogin
            ? 'Login failed. Please try again.'
            : 'Registration failed. Please try again.';
    }
  }
}
