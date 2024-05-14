import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Database {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(data, context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Set the user document
      await users.doc(userId).set(data);

      // Get the current month and year
      String monthYear = DateFormat("MMM y").format(DateTime.now());

      // Add a new document under the 'monthyear' subcollection
      await users.doc(userId).collection('monthyear').doc(monthYear).set({
        'totalIncome': 0,
        'remainAmount': 0,
        'totalCredit': 0,
        'totalDebit': 0,
        'budgetRule': "80/20",
      });

      print("User Added Successfully");
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign Up Failed"),
            content: Text(error.toString()),
          );
        },
      );
    }
  }
}
