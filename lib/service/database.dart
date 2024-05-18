import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Database {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(data, context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Set the user document
      await users.doc(userId).set(data);

      // // Get the current month and year
      // String monthYear = DateFormat("MMM y").format(DateTime.now());

      // // Add a new document under the 'monthyear' subcollection
      // await users.doc(userId).collection('monthyear').doc(monthYear).set({
      //   'totalIncome': 0,
      //   'remainAmount': 0,
      //   'totalCredit': 0,
      //   'totalDebit': 0,
      //   'budgetRule': "80/20",
      // });
    } catch (error) {
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: const Text("Sign Up Failed"),
      //       content: Text(error.toString()),
      //     );
      //   },
      // );
    }
  }

  // Check and create new monthyear file if does not exist
  Future<void> createMonthlyIncomeDocument(String userId, context) async {
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

                  // Format values to 2 decimal places
                  double remainAmount =
                      double.parse((totalIncome).toStringAsFixed(2));
                  double calneeds =
                      double.parse((totalIncome * 0.5).toStringAsFixed(2));
                  double calwants =
                      double.parse((totalIncome * 0.3).toStringAsFixed(2));
                  double calsavings =
                      double.parse((totalIncome * 0.2).toStringAsFixed(2));
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('monthly_income')
                      .doc(currentmonthyear)
                      .set({
                    'totalIncome': totalIncome,
                    'remainAmount': remainAmount,
                    'totalCredit': 0.0,
                    'totalDebit': 0.0,
                    'needs': 0.0,
                    'wants': 0.0,
                    'savings': 0.0,
                    'cal_needs': calneeds,
                    'cal_wants': calwants,
                    'cal_savings': calsavings,
                    'budgetRule': "80/20",
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Income saved successfully!')),
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
