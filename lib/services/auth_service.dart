import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;


Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = _auth.createUserWithEmailAndPassword(email: email, password: password) as UserCredential;
      return credential.user;

    } catch (e) {
      print("Registration failed: $e");
    }
    return null;
  }


  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      // Handle error, e.g., show a message
      print("Login failed: $e");
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      print("Registration failed: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  bool get isLoggedIn => currentUser != null;
}
