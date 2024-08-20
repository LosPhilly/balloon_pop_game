import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isGuest = false;

  User? get user => _user;
  bool get isGuest => _isGuest;

  AuthProvider() {
    // Listen to auth state changes to handle login/logout automatically
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isGuest = user == null;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isGuest = false;

      // Store user info in Firestore with initial stats
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'username': username,
        'score': 0,
        'level': 1,
        'balloonStats': {
          'blue': 0,
          'gold': 0,
          'green': 0,
          'orange': 0,
          'purple': 0,
          'red': 0,
          'silver': 0,
          'star': 0,
          'trick': 0,
          'yellow': 0,
        },
        'balloonsPopped': 0,
      });

      notifyListeners();
    } catch (e) {
      print('Sign Up Error: $e');
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
      print('Sign In Error: $e');
      throw e;
    }
  }

  Future<void> signInAsGuest() async {
    try {
      _user = null;
      _isGuest = true;
      notifyListeners();
    } catch (e) {
      print('Sign In As Guest Error: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out the user from Firebase Auth
      await _auth.signOut();

      // Clear the stored "Remember Me" information from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');

      // Clear the local user state
      _user = null;
      _isGuest = false;
      notifyListeners();
    } catch (e) {
      print('Sign Out Error: $e');
      throw e;
    }
  }

  Future<DocumentSnapshot> getUserStats() async {
    if (_isGuest || _user == null) {
      throw Exception("Guest users do not have stats.");
    }
    return _firestore.collection('users').doc(_user!.uid).get();
  }

  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    if (!_isGuest && _user != null) {
      await _firestore.collection('users').doc(_user!.uid).update(stats);
    }
  }

  Future<void> _saveUserToPrefs(String email, String password,
      {required bool rememberMe}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', rememberMe);
  }

  Future<void> _clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('rememberMe');
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (email != null && password != null && rememberMe) {
      await signIn(email, password);
    }
  }
}
