import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/service/database.dart';
import 'package:ft_v2/widgets/budget/budget_card.dart';
import 'package:ft_v2/widgets/note.dart';
import 'package:ft_v2/widgets/view_card.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final Database _database = Database();
  @override
  void initState() {
    super.initState();
    // Call the function to create a monthly document for the current user
    _database.createMonthlyIncomeDocument(userId, context);
    _database.createMonthlyPointHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String currentDate = DateFormat("dd MMMM").format(date);
    String monthyear = DateFormat("MMM y").format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FinTrack",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[400],
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
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                //TopSplit display total balance, credit and debit
                child: TopSplit(
                  userId: userId,
                  monthYear: monthyear,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            //Expenses breakdown & Leaderboard
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: BudgetCard(
                userId: userId,
                currentMonthYear: monthyear,
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   color: const Color.fromARGB(255, 199, 124, 124),
            //   child: const Column(
            //     children: [
            //       note(),
            //       SizedBox(
            //         height: 10,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
