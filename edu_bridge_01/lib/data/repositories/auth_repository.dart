import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;
  
  AuthRepository() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn();
    } else if (Platform.isIOS) {
      // iOS requires client ID from GoogleService-Info.plist
      _googleSignIn = GoogleSignIn(
        clientId: '605131029565-bg342octcpp0e8vip5aejkk1vvfidjb6.apps.googleusercontent.com',
      );
    } else {
      // Android configuration
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

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
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      return await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      // Mobile Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _firebaseAuth.signInWithCredential(credential);
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

    // Save to main users collection
    await _firestore.collection('users').doc(uid).set(userData);
    
    // Also save to user type specific collection for better indexing
    final typeCollection = _getUserTypeCollection(userType);
    await _firestore.collection(typeCollection).doc(uid).set(userData);
  }
  
  String _getUserTypeCollection(String userType) {
    switch (userType.toLowerCase()) {
      case 'student':
        return 'students';
      case 'teacher':
        return 'teachers';
      case 'parent':
        return 'parents';
      case 'admin':
        return 'admins';
      default:
        return 'users';
    }
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
      // First try exact match in students collection
      var query = await _firestore
          .collection('students')
          .where('name', isEqualTo: cleanName)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      
      // Try case-insensitive search
      final allStudents = await _firestore
          .collection('students')
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
      final query = await _firestore.collection('students').get();
      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  Stream<List<Map<String, dynamic>>> getStudentsStream() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }
  
  Future<List<Map<String, dynamic>>> searchStudents(String searchQuery) async {
    try {
      final allStudents = await getAllRegisteredStudents();
      if (searchQuery.isEmpty) return allStudents;
      
      final query = searchQuery.toLowerCase();
      return allStudents.where((student) {
        final name = student['name']?.toString().toLowerCase() ?? '';
        final email = student['email']?.toString().toLowerCase() ?? '';
        final studentClass = student['studentClass']?.toString().toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || studentClass.contains(query);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getUsersByType(String userType) async {
    try {
      final collection = _getUserTypeCollection(userType);
      final query = await _firestore.collection(collection).get();
      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    return await getUsersByType('Teacher');
  }
  
  Future<List<Map<String, dynamic>>> getAllParents() async {
    return await getUsersByType('Parent');
  }
  
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    return await getUsersByType('Admin');
  }
}