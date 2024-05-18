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

  void _loadDayCount() {
    // Load the day count from wherever you are storing it (e.g., SharedPreferences)
    // For now, I'll set it to a random number for demonstration purposes
    setState(() {
      dayCount = 10; // Set the day count to a random number
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
