import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isGuest = false;

  User? get user => _user;
  bool get isGuest => _isGuest;

  Future<void> signUp(String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isGuest = false;

      // Store user info in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'username': username,
        'score': 0,
        'level': 1,
        // Add other stats here
      });

      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isGuest = false;
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> signInAsGuest() async {
    try {
      _user = null;
      _isGuest = true;
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _isGuest = false;
    notifyListeners();
  }

  Future<DocumentSnapshot> getUserStats() async {
    if (_isGuest) {
      throw Exception("Guest users do not have stats.");
    }
    return _firestore.collection('users').doc(_user!.uid).get();
  }

  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    if (!_isGuest) {
      await _firestore.collection('users').doc(_user!.uid).update(stats);
    }
  }
}
