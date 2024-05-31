import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/pages/loading_screen.dart';
import 'package:ft_v2/service/database.dart';
import 'package:ft_v2/utils/dashboard.dart'; // Assuming this is your dashboard screen

class AuthService {
  var database = Database();

  createUser(data, context) async {
    try {
      // Navigate to the loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      // Add user into Firestore
      await database.addUser(data, context);

      // Replace loading screen with dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Dashboard()), // Replace with your dashboard widget
      );
    } catch (e) {
      Navigator.pop(context); // Close the loading screen
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sign Up Failed"),
            content: Text(e.toString()),
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
