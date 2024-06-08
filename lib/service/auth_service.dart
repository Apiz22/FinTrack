import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class AuthService {
  var database = Database();

  createUser(data, context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      // Add user into Firestore
      await database.addUser(data, context);

      // Navigate to Dashboard after successful registration
      Navigator.pop(
        context,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sign Up Failed"),
            content: Text("Sorry !! This email account already exist"),
          );
        },
      );
    }
  }

  validateUser(data, context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login Failed"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }
}
