import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/gamification/class/badge_class.dart';
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
  String currentmonthyear = DateFormat("MMM y").format(DateTime.now());

  // //to calculate the points
  // double income = 2000;
  // double budget = 0; //will calculate 20% from income
  // double expenses = 0;
  // int points = 0;
  // int totalBadgesObtained = 0;

  // Instance of Badges class
  final Badges badges = Badges();
  int _totalBadgesObtained = 0;

  @override
  void initState() {
    super.initState();
    totalBadges();
    // setBudget();
  }

  // void setBudget() {
  //   setState(() {
  //     budget = income * 0.2;
  //   });
  // }

  logOut() async {
    setState(() {
      isLogOut = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLogOut = false;
    });
  }

  void totalBadges() async {
    int badgesCount = await badges.retrieveTotalBadge();
    setState(() {
      _totalBadgesObtained = badgesCount;
    });
  }

  // void addExpense(double amount) {
  //   setState(() {
  //     expenses += amount;
  //     updatePoints();
  //     updateUserData();
  //   });
  // }

  // void updatePoints() {
  //   double percentageSpent = (expenses / budget) * 100;

  //   // Normalize points based on percentage of budget spent
  //   if (percentageSpent > 100) {
  //     points -= 10; // Deduct points if overspend
  //   } else {
  //     points += (10 * (budget / (income * 0.2)))
  //         .toInt(); // Add points proportionally to the budget
  //   }
  // }

  // Future<void> updateUserData() async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('test')
  //         .doc(currentmonthyear)
  //         .set({
  //       'expenses': expenses,
  //       'points': points,
  //     }, SetOptions(merge: true));
  //   } catch (error) {
  //     print('Error updating user data: $error');
  //   }
  // }

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            //change budget rule
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBudgetRule, // Use the selected value
                  onChanged: (_totalBadgesObtained >= 0)
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
                    enabled: _totalBadgesObtained > 1,
                  ),
                ),
                ElevatedButton(
                  onPressed: (_totalBadgesObtained > 1)
                      ? () {
                          saveBudgetRuleToFirebase(
                              selectedBudgetRule); // Call function to save budget rule
                        }
                      : null,
                  child: const Text('Save'),
                ),
                const SizedBox(height: 50),
                Text('Days App Used: $dayCount'),
                Text("Total user obtained badges: $_totalBadgesObtained"),
                //Test point
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     const SizedBox(
                //       height: 20,
                //     ),
                //     Text("Budget : \$${budget.toStringAsFixed(2)}"),
                //     Text('Expenses: \$${expenses.toStringAsFixed(2)}'),
                //     Text('Points: $points'),
                //     ElevatedButton(
                //         onPressed: () {
                //           addExpense(100); //test using 10
                //         },
                //         child: const Text("Add Expense"))
                //   ],
                // ),
                //list out the all badges obtained
                const SizedBox(height: 20),
                const Text("Hall of Fames"),
                badgesList()
              ],
            ),
          ],
        ),
      ),
    );
  }

  SizedBox badgesList() {
    return SizedBox(
      height: 200,
      child: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: badges.retrieveBadgesList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error loading data");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            final badgesList = snapshot.data!;
            return ListView.builder(
              itemCount: badgesList.length,
              itemBuilder: (context, index) {
                final badge = badgesList[index].data() as Map<String, dynamic>;
                return ListTile(
                  // leading: Image.network(badge['imageUrl']),
                  title: Text(badge['name']),
                  subtitle: Text(badge['description']),
                );
              },
            );
          } else {
            return const Text('No badges obtained');
          }
        },
      ),
    );
  }

  // Function to save the selected budget rule to Firebase
  void saveBudgetRuleToFirebase(String? budgetRule) {
    if (budgetRule != null) {
      FirebaseFirestore.instance.collection("users").doc(userId).update({
        'currentRule': budgetRule,
      }).then((value) {
        print('Budget rule saved successfully!');
      }).catchError((error) {
        print('Failed to save budget rule: $error');
      });
    }
  }
}
