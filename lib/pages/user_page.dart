import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../gamification/class/badge_class.dart';
import '../gamification/points.dart';

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

  // Instance of Badges class
  final Badges badges = Badges();
  final Points points = Points();
  int _totalBadgesObtained = 0;
  int currentPts = 0;
  String currentBudget = "";

  @override
  void initState() {
    super.initState();
    totalBadges();
    getCurrenPtsAndCurrentBudget();
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

  void totalBadges() async {
    int badgesCount = await badges.retrieveTotalBadge();
    setState(() {
      _totalBadgesObtained = badgesCount;
    });
  }

  void test() async {
    await points.userPointStreak(userId);
  }

  void getCurrenPtsAndCurrentBudget() async {
    int curPts = await points.retrieveCurrentPts(userId);
    String curBud = await points.retrieveCurrentBudgetRule(userId);

    setState(() {
      currentPts = curPts;
      currentBudget = curBud;
    });
  }

  void changeCurrentRule() async {
    if (currentPts >= 2000 && currentBudget == "50/30/20") {
      saveBudgetRuleToFirebase("50/30/20");
    } else if (currentPts <= 1000 && currentBudget == "80/20") {
      saveBudgetRuleToFirebase("80/20");
    } else {
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      endDrawer: Drawer(
        child: userDrawer(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                const SizedBox(height: 20),
                Text("Current Points: $currentPts"),
                ElevatedButton(
                  onPressed: changeCurrentRule,
                  child: const Text("Update Rule based on Points"),
                ),
                Text('Days App Used: $dayCount'),
                ElevatedButton(
                  onPressed: test,
                  child: const Text("Test update win streak"),
                ),
                Text("Total Badges Obtained: $_totalBadgesObtained"),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Hall of Fame"),
                      badgesList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ListView userDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.teal,
          ),
          child: const Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Budget Rule'),
          onTap: () {
            Navigator.pop(context);
            editBudgetRule(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Log Out'),
          onTap: () {
            Navigator.pop(context);
            logOut();
          },
        ),
      ],
    );
  }

  Future<dynamic> editBudgetRule(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Budget Rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedBudgetRule,
                onChanged: (_totalBadgesObtained >= 0)
                    ? (String? value) {
                        setState(() {
                          selectedBudgetRule = value;
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
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: (_totalBadgesObtained > 1)
                  ? () {
                      saveBudgetRuleToFirebase(selectedBudgetRule);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  SizedBox badgesList() {
    return SizedBox(
      height: 500,
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
            return Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade200,
              child: ListView.builder(
                itemCount: badgesList.length,
                itemBuilder: (context, index) {
                  final badge =
                      badgesList[index].data() as Map<String, dynamic>;
                  final imageUrl = badge['imageUrl'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (index % 2 == 0)
                            ? Colors.teal.shade100
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: ListTile(
                        leading: ClipOval(
                          child: Container(
                            color: Colors.grey.shade300,
                            padding: const EdgeInsets.all(1),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.white),
                          ),
                        ),
                        title: Text(badge['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(badge['description']),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text('No badges obtained');
          }
        },
      ),
    );
  }

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
