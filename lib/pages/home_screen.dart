import 'package:FinTrack/gamification/points.dart';
import 'package:FinTrack/pages/summary.dart';
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
        backgroundColor: Colors.teal.shade900,
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
              child: BudgetCard(
                userId: userId,
                currentIncome: currentIncomeDate,
              ),
            ),
            SummaryHistory(
              currentMonth: currentIncomeDate,
              userId: userId,
            )
          ],
        ),
      ),
    );
  }
}
