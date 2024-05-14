import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var isLogOut = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  DateTime date = DateTime.now();
  String? selectedBudgetRule;

  bool incomeDialogShown = false; // Flag to track if the dialog has been shown

  logOut() async {
    setState(() {
      isLogOut = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLogOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current date is the 17th day of the month
    bool is30Day = date.day == 29 && !incomeDialogShown;

    // Show a dialog if it's the 17th day of the month
    if (is30Day) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Page"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: isLogOut
                ? const CircularProgressIndicator()
                : const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedBudgetRule, // Use the selected value
            onChanged: (String? value) {
              setState(() {
                selectedBudgetRule = value; // Update the selected value
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: '80/20',
                child: Text('80/20'),
              ),
              DropdownMenuItem<String>(
                value: '50/30/20',
                child: Text('50/30/20'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              saveBudgetRuleToFirebase(
                  selectedBudgetRule); // Call function to save budget rule
            },
            child: Text('Save'),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: const Center(
              child: Text("User"),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the dialog
  void _showDialog() {
    TextEditingController incomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Insert Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: incomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Income',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Get the entered income value
                String income = incomeController.text;

                // Save the income to Firebase
                _saveIncomeToFirebase(income);

                // Set the flag to true to indicate that the dialog has been shown
                setState(() {
                  incomeDialogShown = true;
                });

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveIncomeToFirebase(String income) {
    String monthyear = DateFormat("MMM y").format(date);
    // Access Firebase and save the income data
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection('monthyear')
        .doc(monthyear)
        .update({
      'remainAmount': income,
      'totalIncome': income,
    }).then((value) {
      // Handle success
      print('Income saved successfully!');
    }).catchError((error) {
      // Handle error
      print('Failed to save income: $error');
    });
  }

  // Function to save the selected budget rule to Firebase
  void saveBudgetRuleToFirebase(String? budgetRule) {
    if (budgetRule != null) {
      String monthYear = DateFormat("MMM y").format(date);
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection('monthyear')
          .doc(monthYear)
          .update({
        'budgetRule': budgetRule,
      }).then((value) {
        print('Budget rule saved successfully!');
      }).catchError((error) {
        print('Failed to save budget rule: $error');
      });
    }
  }
}
