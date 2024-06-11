import 'package:FinTrack/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeInputPage extends StatefulWidget {
  final String userId;

  IncomeInputPage({super.key, required this.userId});

  @override
  State<IncomeInputPage> createState() => _IncomeInputPageState();
}

final Database database = Database();

class _IncomeInputPageState extends State<IncomeInputPage> {
  final TextEditingController incomeController = TextEditingController();

  String currentMonthYear = DateFormat("MMM y").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    incomeController.addListener(_formatIncomeInput);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Total Income',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Enter Your Monthly Income for ${currentMonthYear}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: incomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '(RM) Total Income',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
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
                          .doc(widget.userId)
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
                        'budgetRule': await database
                            .getNextMonthUserBudgetRule(widget.userId),
                        'currentLevel': await getUserCurrentLvl(widget.userId),
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Income saved successfully!')),
                        );
                        Navigator.of(context)
                            .pop(); // Close the page and return to the main page
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to save data: $error')),
                        );
                      });
                    },
                    icon: Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _formatIncomeInput() {
    final text = incomeController.text;
    if (text.isNotEmpty) {
      // Check if the input contains a decimal point
      if (text.contains('.')) {
        // Split the input into parts before and after the decimal point
        List<String> parts = text.split('.');
        String wholeNumber = parts[0];
        String decimalPart = parts.length > 1 ? parts[1] : '';

        // Limit the decimal part to two digits
        if (decimalPart.length > 2) {
          decimalPart = decimalPart.substring(0, 2);
        }

        // Update the text in the TextEditingController
        incomeController.value = incomeController.value.copyWith(
          text: '$wholeNumber.$decimalPart',
          selection: TextSelection.collapsed(
              offset: '$wholeNumber.$decimalPart'.length),
        );
      }
    }
  }

  // Future<String> _getUserBudgetRule(String userId) async {
  //   final userDoc =
  //       await FirebaseFirestore.instance.collection('users').doc(userId).get();
  //   return userDoc.exists ? userDoc["currentRule"] ?? "" : "";
  // }

  Future<String> getUserCurrentLvl(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc["currentLevel"] ?? "" : "";
  }
}
