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

  Future<String> getUserBudgetRule(String userId) async {
    final userDoc = await users.doc(userId).get();
    return userDoc.exists ? userDoc["currentRule"] ?? "" : "";
  }

  Future<void> createMonthlyPointHistory(String userId) async {
    final docRef =
        users.doc(userId).collection('point_history').doc(currentMonthYear);
    final documentExists = await docRef.get().then((doc) => doc.exists);

    if (!documentExists) {
      final budgetRule = await getUserBudgetRule(userId);
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

    // final prefs = await SharedPreferences.getInstance();
    // final alertShownKey = 'alert_shown_$currentMonthYear';

    if (!documentExists) {
      // prefs.setBool(alertShownKey, true); // Set flag to true
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncomeInputPage(userId: userId),
        ),
      );
    }
  }

  Stream<DocumentSnapshot> getPointsStream(String userId, String monthYear) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection('point_history')
        .doc(monthYear)
        .snapshots();
  }

  void saveBudgetRuleToFirebase(String? budgetRule) {
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

  // Future<void> determineUserBudgetRuleChange(String userId, monthYear) async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   DocumentSnapshot userDoc =
  //       await firestore.collection('users').doc(userId).get();
  //   DocumentSnapshot ptsDoc = await firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('point_history')
  //       .doc(monthYear)
  //       .get();
  //   final documentSnapshot = ptsDoc;
  //   final documentExists = documentSnapshot.exists;

  //   if (documentExists) {
  //     double currentPts = ptsDoc["CurrentPoints"];
  //     String budgetRule = ptsDoc["budgetRule"];
  //     int ruleStreak = userDoc["ruleStreak"] ?? 0; // Default to 0 if null

  //     if ((budgetRule == "80/20" && currentPts == 1000) ||
  //         (budgetRule == "50/30/20" && currentPts == 2000)) {
  //       ruleStreak += 1;
  //     } else {
  //       ruleStreak = 0; // Reset streak if conditions are not met
  //     }

  //     await FirebaseFirestore.instance.collection("users").doc(userId).update({
  //       "ruleStreak": ruleStreak,
  //     });
  //   }
  // }
}
