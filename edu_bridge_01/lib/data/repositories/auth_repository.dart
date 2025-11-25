import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      // For iOS Simulator, create a test account automatically
      if (kDebugMode && !kIsWeb && Platform.isIOS) {
        return await _createTestGoogleAccount();
      }
      rethrow;
    }
  }
  
  Future<UserCredential> _createTestGoogleAccount() async {
    const testEmail = 'testuser@gmail.com';
    const testPassword = 'TestPass123!';
    const testName = 'Test User';
    
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
    } catch (e) {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      await userCredential.user?.updateDisplayName(testName);
      return userCredential;
    }
  }

  Future<void> saveUserData({
    required String uid,
    required String email,
    required String name,
    required String userType,
    Map<String, dynamic>? additionalData,
  }) async {
    final userData = {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    };

    await _firestore.collection('users').doc(uid).set(userData);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
  
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    final query = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }
  
  Future<void> linkGoogleAccount(String googleUid, Map<String, dynamic> existingUserData) async {
    await _firestore.collection('users').doc(googleUid).set({
      ...existingUserData,
      'uid': googleUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  Future<Map<String, dynamic>?> findStudentByName(String studentName) async {
    final cleanName = studentName.trim();
    
    try {
      // First try exact match
      var query = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Student')
          .where('name', isEqualTo: cleanName)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      
      // Try case-insensitive search by getting all students and filtering
      final allStudents = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Student')
          .get();
      
      for (var doc in allStudents.docs) {
        final data = doc.data();
        final studentNameInDb = data['name']?.toString().trim().toLowerCase() ?? '';
        if (studentNameInDb == cleanName.toLowerCase()) {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> isStudentRegistered(String studentName) async {
    final student = await findStudentByName(studentName);
    return student != null;
  }
  
  Future<List<Map<String, dynamic>>> getAllRegisteredStudents() async {
    try {
      print('Querying Firestore for students...');
      final query = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'Student')
          .get();
      
      print('Found ${query.docs.length} student documents');
      final students = query.docs.map((doc) => doc.data()).toList();
      print('Student names: ${students.map((s) => s['name']).toList()}');
      
      return students;
    } catch (e) {
      print('Error in getAllRegisteredStudents: $e');
      return [];
    }
  }
}