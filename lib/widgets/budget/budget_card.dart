import 'package:FinTrack/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../gamification/class/badge_class.dart';
import '../../gamification/progress_bar.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard(
      {super.key, required this.userId, required this.currentIncome});

  final String userId;
  final String currentIncome;

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  String nextBudget = "";
  final Database database = Database();

  @override
  void initState() {
    super.initState();
    getNextBudget();
  }

  Future<void> getNextBudget() async {
    String budget = await database.getNextMonthUserBudgetRule(widget.userId);
    setState(() {
      nextBudget = budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('monthly_income')
        .doc(widget.currentIncome)
        .snapshots();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade900,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Text(
                "Expenses Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            StreamBuilder(
              stream: usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Something went wrong'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Loading"),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Data not available'),
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                double calNeeds = data["cal_needs"];
                double calWants = data["cal_wants"];
                double calSavings = data["cal_savings"];
                double needs = data["needs"];
                double wants = data["wants"];
                double savings = data["savings"];
                String budgetRule = data["budgetRule"];

                // Instance of Badges class
                final Badges badges = Badges();

                // Function to handle awarding the badge
                void awardSavingsBadge() {
                  badges.awardBadge("Savings is my Goal", context);
                }

                // Variables to store progress percentages
                double needsPercent = needs / calNeeds;
                double wantsPercent = wants / calWants;
                double savingsPercent = savings / calSavings;

                // Determine the budget rows based on the budget rule
                List<Widget> budgetRows;
                if (budgetRule == '80/20') {
                  // Calculate the combined amounts for Needs and wants
                  double combinedWantsNeeds = wants + needs;
                  double combinedCalWantsNeeds = calWants + calNeeds;
                  double combinedWantsNeedsPercentage =
                      combinedWantsNeeds / combinedCalWantsNeeds;
                  if (combinedWantsNeedsPercentage == 1.0 &&
                      savingsPercent == 1.0) {
                    badges.awardBadge("Reach Goal 80/20", context);
                  }

                  budgetRows = [
                    buildRow(
                      context,
                      "Wants & Needs",
                      combinedWantsNeeds,
                      combinedCalWantsNeeds,
                      "\nNeeds: These are expenses that are essential for survival and well-being. They include items like housing, utilities, food, healthcare, and transportation. If you stopped spending money on these items, there would be severe negative consequences." +
                          "\nWants: These are non-essential expenses that enhance your quality of life but are not necessary for survival. Examples include dining out, entertainment, and gym memberships. Wants may improve your life but cutting them from your budget wouldn’t have the same severe consequences as cutting needs.",
                      () {},
                    ),
                    buildRow(
                      context,
                      "Savings",
                      savings,
                      calSavings,
                      "Savings are kept in the form of cash or cash equivalents (e.g. as bank deposits), which are exposed to no risk of loss but also come with correspondingly minimal returns.",
                      awardSavingsBadge,
                    ),
                  ];
                } else {
                  if (needsPercent == 1.0 &&
                      wantsPercent == 1.0 &&
                      savingsPercent == 1.0) {
                    badges.awardBadge("Reach Goal 50/30/20", context);
                  }
                  budgetRows = [
                    buildRow(
                      context,
                      "Needs",
                      needs,
                      calNeeds,
                      "Needs — as you may gathered — are the things that you absolutely cannot do without. They are those goods and services that you must have to lead a decent life. The most common needs are air, food, water, clothing and shelter. Without these basic necessities, your life may be extremely challenging or downright hard.",
                      () {},
                    ),
                    buildRow(
                      context,
                      "Wants",
                      wants,
                      calWants,
                      "Wants, or discretionary expenses, are the things that you don’t really need. They are the costs of the products and services that you would like to have. If it comes down to it, you can eliminate all the wants or inessential expenses from your budget and still lead a fairly comfortable life.",
                      () {},
                    ),
                    buildRow(
                      context,
                      "Savings",
                      savings,
                      calSavings,
                      "Savings are kept in the form of cash or cash equivalents (e.g. as bank deposits), which are exposed to no risk of loss but also come with correspondingly minimal returns.",
                      awardSavingsBadge,
                    ),
                  ];
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.teal.shade50,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Your current Budget & Level: ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${data["budgetRule"]} (${data['currentLevel']})',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: ((context) {
                                            return AlertDialog(
                                              title: Text("About Level"),
                                              content: Text("Level can be into 3 category :" +
                                                  "\n 1) Beginner - Achieve when you cannot achieve the any budget rule yet" +
                                                  "\n 2) Intermediate - Achieve when you follow the rule 80/20" +
                                                  "\n 3) Expert - Achieve when you can follow the 50/30/20" +
                                                  "\n Reminder** Your budget can change based on your monthly transactions"),
                                              actions: <Widget>[
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Close"))
                                              ],
                                            );
                                          }));
                                    },
                                    icon: Icon(Icons.info))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Text(
                              "Next Month Budget:",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$nextBudget",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: ((context) {
                                            return AlertDialog(
                                              title: Text("How to change"),
                                              content: Text(
                                                  "1) This can will change when you can achive the budget rule montly." +
                                                      "\n2) You can change this budget rule in your profile when you reach your monthly goals and the the current level is intermediate or expert. " +
                                                      "\n3) You can stick to the current budget rule  by change it at profile."),
                                              actions: <Widget>[
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Close"))
                                              ],
                                            );
                                          }));
                                    },
                                    icon: Icon(Icons.info))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...budgetRows,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(BuildContext context, String header, double amount,
      double calAmount, String description, VoidCallback onComplete) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          budgetCategory(
              context, header, amount, calAmount, description, onComplete),
        ],
      ),
    );
  }

  Expanded budgetCategory(BuildContext context, String header, double amount,
      double calAmount, String description, VoidCallback onComplete) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          border: Border.all(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            header,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          //info budget
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(header),
                                  content: SingleChildScrollView(
                                    child: Text(description),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      "RM ${amount.toStringAsFixed(2)} / ${calAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ProgressBar(
                percent: amount / calAmount,
                onComplete: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
