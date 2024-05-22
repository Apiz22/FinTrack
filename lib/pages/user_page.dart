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
  int dayCount = 0;
  int totalBadgesObtained = 0;
  //to calculate the points
  double income = 0;
  double budget = 0;
  double expenses = 0;
  int points = 0;

  @override
  void initState() {
    super.initState();
    _loadDayCount();
  }

  logOut() async {
    setState(() {
      isLogOut = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLogOut = false;
    });
  }

//load day count
  void _loadDayCount() {
    // Load the day count from wherever you are storing it (e.g., SharedPreferences)
    // For now, I'll set it to a random number for demonstration purposes
    setState(() {
      dayCount = 10; // Set the day count to a random number
    });
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          income = userDoc['income'];
          budget = userDoc['budget'];
          expenses = userDoc['expenses'];
          points = userDoc['points'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void addExpense(double amount) {
    setState(() {
      expenses += amount;
      updatePoints();
    });
    updateUserData();
  }

  void updatePoints() {
    double budgetLimit = (budget / 100) * income;
    double percentageSpent = (expenses / budgetLimit) * 100;

    if (percentageSpent > 100) {
      points -= 10; // Deduct points if overspend
    } else {
      points += 10; // Add points if within budget
    }
  }

  Future<void> updateUserData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'expenses': expenses,
        'points': points,
      });
    } catch (error) {
      print('Error updating user data: $error');
    }
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
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text("Error loading badges");
              }
              if (snapshot.hasData) {
                var userDoc = snapshot.data!;
                totalBadgesObtained = userDoc['totalBadgesObtained'] ?? 0;
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedBudgetRule, // Use the selected value
                      onChanged: (totalBadgesObtained > 3)
                          ? (String? value) {
                              setState(() {
                                selectedBudgetRule =
                                    value; // Update the selected value
                              });
                            }
                          : null,
                      items: const [
                        DropdownMenuItem<String>(
                          value: '80/20',
                          child: Text('80/20'),
                        ),
                        DropdownMenuItem<String>(
                          value: '50/30/20',
                          child: Text('50/30/20'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Budget Rule',
                        enabled: totalBadgesObtained > 3,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (totalBadgesObtained > 3)
                          ? () {
                              saveBudgetRuleToFirebase(
                                  selectedBudgetRule); // Call function to save budget rule
                            }
                          : null,
                      child: const Text('Save'),
                    ),
                    const SizedBox(height: 50),
                    Text('Days App Used: $dayCount'),
                    Text("Total user obtained badges: $totalBadgesObtained"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Budget : \$${budget.toStringAsFixed(2)}"),
                        Text('Expenses: \$${expenses.toStringAsFixed(2)}'),
                        Text('Points: $points'),
                        ElevatedButton(
                            onPressed: () {
                              addExpense(50); //test using 50
                            },
                            child: const Text("Add Expense"))
                      ],
                    )
                  ],
                );
              }
              return const Text("No data available");
            },
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
          .collection('monthly_income')
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
