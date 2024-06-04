import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Points {
  static const int pointsLimit502030 = 2000;
  static const int pointsLimit8020 = 1000;

  int calculatePoints(String budgetRule, double amount, double expenses,
      double calbudget, double income, String category, double combine) {
    int points = 0;
    double combineNeedsSavings = income * 0.8;
    int weight = 0;

    switch (budgetRule) {
      case '50/30/20':
        if (category == "needs") {
          int weight = 100;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        } else if (category == "wants") {
          weight = 60;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        } else {
          weight = 40;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        }
      case '80/20':
        if (category == "needs" || category == "wants") {
          weight = 80;
          points = calculatePointsForBudget(
              amount, combine, combineNeedsSavings, weight);
          break;
        } else if (category == "savings") {
          weight = 20;
          points =
              calculatePointsForBudget(amount, expenses, calbudget, weight);
          break;
        } else {
          print("other");
          break;
        }
      default:
        // Handle other cases or throw an error
        break;
    }

    return points;
  }

  int calculatePointsForBudget(
      double amount, double expenses, double calbudget, int weight) {
    int calPoints = 0;
    double over = 0;
    if (expenses > calbudget) {
      over = expenses - calbudget;
      calPoints = ((10 * weight) - over).toInt(); // Deduct points if overspend
      // calPoints = amount.toInt();
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

  // //if user got achieve the points it will get streak
  // Future<void> userPointStreak(String userId) async {
  //   // DateTime date = DateTime.now();
  //   // String monthYear = DateFormat("MMM y").format(date);

  //   try {
  //     int currentPts = await retrieveCurrentPts(userId);
  //     String currentBudget = await retrieveCurrentBudgetRule(userId);

  //     FirebaseFirestore firestore = FirebaseFirestore.instance;

  //     DocumentSnapshot userDoc =
  //         await firestore.collection('users').doc(userId).get();

  //     int winStreak = userDoc["ruleWinStreak"] ?? 0;

  //     if ((currentPts == 1000 && currentBudget == "80/20") ||
  //         (currentPts == 2000 && currentBudget == "50/30/20")) {
  //       winStreak += 1;
  //     } else {
  //       winStreak = 0;
  //     }

  //     await firestore.collection("users").doc(userId).update({
  //       "ruleWinStreak": winStreak,
  //     });
  //   } catch (e) {
  //     print("Error updating win streak: $e");
  //   }
  // }
}
