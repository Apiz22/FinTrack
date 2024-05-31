import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeInputPage extends StatelessWidget {
  final TextEditingController incomeController = TextEditingController();
  final String userId;

  IncomeInputPage({super.key, required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Total Income'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Income',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String totalIncomeStr = incomeController.text;
                double totalIncome = double.parse(totalIncomeStr);

                String currentMonthYear =
                    DateFormat("MMM y").format(DateTime.now());
                double remainAmount =
                    double.parse((totalIncome).toStringAsFixed(2));
                double calNeeds =
                    double.parse((totalIncome * 0.5).toStringAsFixed(2));
                double calWants =
                    double.parse((totalIncome * 0.3).toStringAsFixed(2));
                double calSavings =
                    double.parse((totalIncome * 0.2).toStringAsFixed(2));

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('monthly_income')
                    .doc(currentMonthYear)
                    .set({
                  'totalIncome': totalIncome,
                  'remainAmount': remainAmount,
                  'totalCredit': 0.0,
                  'totalDebit': 0.0,
                  'needs': 0.0,
                  'wants': 0.0,
                  'savings': 0.0,
                  'cal_needs': calNeeds,
                  'cal_wants': calWants,
                  'cal_savings': calSavings,
                  'budgetRule': await _getUserBudgetRule(userId),
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Income saved successfully!')),
                  );
                  Navigator.of(context)
                      .pop(); // Close the page and return to the main page
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save data: $error')),
                  );
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getUserBudgetRule(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc["currentRule"] ?? "" : "";
  }
}
