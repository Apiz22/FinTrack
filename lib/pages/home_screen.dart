import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/budget_card.dart';
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
  @override
  void initState() {
    super.initState();
    // Call the function to create a monthly document for the current user
    createMonthlyIncomeDocument(userId);
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
            const SizedBox(),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 199, 124, 124),
              child: const Column(
                children: [
                  note(),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            //Expenses breakdown
            Padding(
              padding: EdgeInsets.all(10.0),
              child: BudgetCard(
                userId: userId,
                currentMonthYear: monthyear,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Check and create new monthyear file if does not exist
  Future<void> createMonthlyIncomeDocument(String userId) async {
    String currentmonthyear = DateFormat("MMM y").format(DateTime.now());

    bool documentExists = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_income')
        .doc(currentmonthyear)
        .get()
        .then((doc) => doc.exists);

    if (!documentExists) {
      // Show dialog to get total income from the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController incomeController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Total Income'),
            content: TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Income'),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Get the entered total income value
                  String totalIncomeStr = incomeController.text;
                  double totalIncome = double.parse(totalIncomeStr);

                  // Save the total income and other initial values to Firebase
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('monthly_income')
                      .doc(currentmonthyear)
                      .set({
                    'totalIncome': totalIncome,
                    'remainAmount': totalIncome,
                    'totalCredit': 0.0,
                    'totalDebit': 0.0,
                    'needs': 0.0,
                    'wants': 0.0,
                    'savings': 0.0,
                    'cal_needs': totalIncome * 0.5,
                    'cal_wants': totalIncome * 0.3,
                    'cal_savings': totalIncome * 0.2,
                    'budgetRule': "80/20",
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: const Text('Income saved successfully!')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to data: $error')),
                    );
                  });

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }
}
