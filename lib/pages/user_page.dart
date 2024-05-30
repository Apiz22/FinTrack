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

  // Instance of Badges class
  final Badges badges = Badges();
  int _totalBadgesObtained = 0;

  @override
  void initState() {
    super.initState();
    totalBadges();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Page"),
        backgroundColor: Colors.green,
      ),
      endDrawer: Drawer(
        child: userDrawer(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(height: 20),
            Column(
              children: [
                const SizedBox(height: 50),
                Text('Days App Used: $dayCount'),
                Text("Total user obtained badges: $_totalBadgesObtained"),
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

//user drawer
  ListView userDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.green,
          ),
          child: Text(
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
            showDialog(
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
            return Container(
              color: Colors.grey[200], // Set ListView background color to grey
              child: ListView.builder(
                itemCount: badgesList.length,
                itemBuilder: (context, index) {
                  final badge =
                      badgesList[index].data() as Map<String, dynamic>;
                  final imageUrl = badge['imageUrl'] ?? '';

                  return Container(
                    color: (index % 2 == 0)
                        ? Color.fromARGB(255, 40, 180, 22)
                        : Color.fromARGB(255, 181, 179, 182),
                    child: ListTile(
                      leading: ClipOval(
                        child: Container(
                          color: const Color.fromARGB(255, 175, 174, 175),
                          padding: const EdgeInsets.all(
                              1), // Add padding for round shape
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
                          const Text("test"),
                        ],
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
