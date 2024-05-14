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

  bool incomeDialogShown = false;

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
              const DropdownMenuItem<String>(
                value: '80/20',
                child: Text('80/20'),
              ),
              const DropdownMenuItem<String>(
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
            child: const Text('Save'),
          ),
          const SizedBox(height: 50),
          const Expanded(
            child: Center(
              child: Text("User"),
            ),
          ),
        ],
      ),
    );
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
