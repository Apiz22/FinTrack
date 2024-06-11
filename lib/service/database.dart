import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pages/income_input.dart';

class Database {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String currentMonthYear = DateFormat("MMM y").format(DateTime.now());

  Future<void> addUser(data, context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await users.doc(userId).set(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully")),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sign Up Failed"),
            content: Text(error.toString()),
          );
        },
      );
    }
  }

  Future<String> getCurrentUserBudgetRule(String userId) async {
    final userDoc = await users.doc(userId).get();
    return userDoc.exists ? userDoc["currentRule"] ?? "" : "";
  }

  Future<String> getNextMonthUserBudgetRule(String userId) async {
    final userDoc = await users.doc(userId).get();
    return userDoc.exists ? userDoc["nextBudget"] ?? "" : "";
  }

  Future<void> createMonthlyPointHistory(String userId) async {
    final docRef =
        users.doc(userId).collection('point_history').doc(currentMonthYear);
    final documentExists = await docRef.get().then((doc) => doc.exists);

    if (!documentExists) {
      final budgetRule = await getCurrentUserBudgetRule(userId);
      await docRef.set({
        "budgetRule": budgetRule,
        "CurrentPoints": 0,
        "NeedsPoints": 0,
        "WantsPoints": 0,
        "SavingsPoints": 0,
      });
    }
  }

  Future<void> createMonthlyIncomeDocument(
      String userId, BuildContext context) async {
    bool documentExists = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_income')
        .doc(currentMonthYear)
        .get()
        .then((doc) => doc.exists);

    if (!documentExists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncomeInputPage(userId: userId),
        ),
      );
    }
  }

  // Future<void> createMonthlyExpensesRecord(String userId) async {
  //   final docExpRec =
  //       users.doc(userId).collection('expenses_record').doc(currentMonthYear);
  //   final documentExists = await docExpRec.get().then((doc) => doc.exists);

  //   if (!documentExists) {
  //     final budgetRule = await getCurrentUserBudgetRule(userId);
  //     await docExpRec.set({
  //       "budgetRule": budgetRule,
  //       "Total Income": 0,
  //       "Level": "Beginner",
  //     });
  //   }
  // }

  Stream<DocumentSnapshot> getPointsStream(String userId, String monthYear) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection('point_history')
        .doc(monthYear)
        .snapshots();
  }

  void UpdateCurrentBudgetRuleToFirebase(String? budgetRule) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (budgetRule != null) {
      FirebaseFirestore.instance.collection("users").doc(userId).update({
        'currentRule': budgetRule,
      }).then((value) {
        print('Budget rule saved successfully!');
      }).catchError((error) {
        print('Failed to save budget rule: $error');
      });
    }
  }

  void UpgradechangeRuleBasedOnPts(String budgetRule) {
    if ((budgetRule == "80/20") || (budgetRule == "50/30/20")) {
      updateNextRuleToFirebase("50/30/20");
    }
  }

  void DownchangeRuleBasedOnPts(String budgetRule) {
    if ((budgetRule == "80/20") || (budgetRule == "50/30/20")) {
      updateNextRuleToFirebase("80/20");
    }
  }

  void updateNextRuleToFirebase(String? nextBudgetRule) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (nextBudgetRule != null) {
      FirebaseFirestore.instance.collection("users").doc(userId).update({
        'nextBudget': nextBudgetRule,
      }).catchError((error) {
        print('Failed to update budget rule: $error');
      });
    }
  }

  Future<int> getUserWinStreak(String userId) async {
    final userDoc = await users.doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;
      return data?["ruleWinStreak"] ?? 0;
    } else {
      return 0;
    }
  }

  Future<double> getRemainAmount() async {
    // Get the current month and year in "MMM y" format
    String currentMonthYear = DateFormat("MMM y").format(DateTime.now());
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the document
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_income')
        .doc(currentMonthYear)
        .get();

    // Check if the document exists
    if (userDoc.exists) {
      // Safely cast the data to a Map
      final data = userDoc.data();
      // Return the remainAmount or 0 if it doesn't exist
      return data?["remainAmount"] ?? 0.0;
    } else {
      // Return 0 if the document does not exist
      return 0.0;
    }
  }
}
