import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Points {
  int calculatePointsForBudget(double expenses, double calbudget, int weight) {
    int calPoints = 0;
    double over = 0;
    if (expenses > calbudget) {
      over = expenses - calbudget;
      calPoints = ((10 * weight) - over).toInt();
    } else {
      calPoints = (10 * ((expenses / calbudget) * weight)).toInt();
    }

    return calPoints;
  }

  // Retrieve points and update the total badge count
  Future<int> retrieveCurrentPts(String userId) async {
    DateTime date = DateTime.now();
    String monthYear = DateFormat("MMM y").format(date);
    int currentPts = 0;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the user's current points
      DocumentSnapshot userPtsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('point_history')
          .doc(monthYear)
          .get();

//check if the document exist and retrieve the poits
      if (userPtsDoc.exists) {
        currentPts = userPtsDoc["CurrentPoints"] ?? 0;
      } else {
        print("Document does not exist for month: $monthYear");
      }
    } catch (e) {
      print("Error retrieving currentPts: $e");
    }

    return currentPts;
  }

  // Retrieve user_badges and update the total badge count
  Future<String> retrieveCurrentBudgetRule(String userId) async {
    DateTime date = DateTime.now();
    String monthYear = DateFormat("MMM y").format(date);
    String curBudgetRule = "";
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the user's current points
      DocumentSnapshot userPtsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('point_history')
          .doc(monthYear)
          .get();

//check if the document exist and retrieve the poits
      if (userPtsDoc.exists) {
        curBudgetRule = userPtsDoc["budgetRule"];
      } else {
        print("Document does not exist for month: $monthYear");
      }
    } catch (e) {
      print("Error retrieving currentPts: $e");
    }

    return curBudgetRule;
  }

  int calculatePointsSavings(double savings, double calSaving, double income) {
    int calPoints = 0;
    double savingPercent = (savings / calSaving) * 100;

    if (savingPercent < 200) {
      calPoints = (savingPercent ~/ 10) * 10;
    }

    return calPoints;
  }
}
