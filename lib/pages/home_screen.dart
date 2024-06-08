import 'package:FinTrack/gamification/points.dart';
import 'package:FinTrack/gamification/view_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/database.dart';
import '../widgets/budget/budget_card.dart';
import '../widgets/view_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

DateTime date = DateTime.now();
String currentDate = DateFormat("dd MMMM").format(date);
String currentIncomeDate = DateFormat("MMM y").format(date);

class _MainPageState extends State<MainPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final Database database = Database();
  final Points pts = Points();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      await database.createMonthlyIncomeDocument(userId, context);
      await database.createMonthlyPointHistory(userId);
      // await pts.userPointStreak(userId);
    } catch (error) {
      print("Initialization error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FinTrack",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentDate,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.teal.shade300,
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //       begin: Alignment.bottomRight,
              //       end: Alignment.bottomLeft,
              //       colors: [Colors.blue, Colors.red]),
              // ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                //view top 3 (total balance, credit and debit)
                child: TopSplit(
                  userId: userId,
                  monthYear: currentIncomeDate,
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                //display the progress bar
                child: BudgetCard(
                  userId: userId,
                  currentIncome: currentIncomeDate,
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   color: const Color.fromARGB(255, 199, 124, 124),
            //   child: const Column(
            //     children: [
            //       Note(),
            //       SizedBox(
            //         height: 10,
            //       ),
            //     ],
            //   ),
            // ),
            ViewHistory(
              userId: userId,
            ),
            //   Container(
            //     padding: const EdgeInsets.all(10),
            //     color: Color.fromARGB(255, 115, 114, 114),
            //     child: const Column(
            //       children: [
            //         DebtReminder(),
            //       ],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

// Function to save the selected budget rule to Firebase
  void saveBudgetRuleToFirebase(String? budgetRule) {
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
}
