import 'package:FinTrack/service/database.dart';
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
  String username = "";
  String profilePicturePath =
      'assets/img/default.png'; // Default profile picture path

  final List<String> profilePictures = [
    'assets/img/default.png',
    'assets/img/pedro.jpeg',
    'assets/img/default.png',
    'assets/img/default.png',
    'assets/img/default.png',
    'assets/img/default.png'
  ];

  Database database = Database();

  @override
  void initState() {
    super.initState();
    totalBadges();
    getCurrenPtsAndCurrentBudget();
    getUsername();
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

  void getCurrenPtsAndCurrentBudget() async {
    int curPts = await points.retrieveCurrentPts(userId);
    String curBud = await points.retrieveCurrentBudgetRule(userId);

    setState(() {
      currentPts = curPts;
      currentBudget = curBud;
    });
  }

  void getUsername() async {
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    setState(() {
      username = userDoc["username"];
      profilePicturePath = userDoc["profilePicture"] ?? profilePicturePath;
    });
  }

  void changeCurrentRule() async {
    if (currentPts >= 2000 && currentBudget == "50/30/20") {
      database.saveBudgetRuleToFirebase("50/30/20");
    } else if (currentPts <= 1000 && currentBudget == "80/20") {
      database.saveBudgetRuleToFirebase("80/20");
    } else {
      return _showIneligibleDialog(context);
    }
  }

  void _showIneligibleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not Eligible'),
          content: Text('You are not eligible to change the rule.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveProfilePicture(String picturePath) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      'profilePicture': picturePath,
    }).then((value) {
      setState(() {
        profilePicturePath = picturePath;
      });
      print('Profile picture updated successfully!');
    }).catchError((error) {
      print('Failed to update profile picture: $error');
    });
  }

  Future<void> changePhoneNumber(String newPhoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      await user?.updatePhoneNumber(PhoneAuthProvider.credential(
        verificationId: '', // you need to provide verificationId and smsCode
        smsCode: '', // from the phone verification process
      ));
      print('Phone number updated successfully!');
    } catch (e) {
      print('Failed to update phone number: $e');
    }
  }

  Future<void> changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      await user?.updatePassword(newPassword);
      print('Password updated successfully!');
    } catch (e) {
      print('Failed to update password: $e');
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
                Text("Total Badges Obtained: $_totalBadgesObtained"),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Badges Collections",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(profilePicturePath),
              ),
              const SizedBox(height: 10),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
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
          leading: const Icon(Icons.phone),
          title: const Text('Edit Phone Number'),
          onTap: () {
            Navigator.pop(context);
            editPhoneNumber(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Edit Password'),
          onTap: () {
            Navigator.pop(context);
            editPassword(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Change Profile Picture'),
          onTap: () {
            Navigator.pop(context);
            changeProfilePicture(context);
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
                      database.saveBudgetRuleToFirebase(selectedBudgetRule);
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

  Future<dynamic> editPhoneNumber(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'New Phone Number',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                changePhoneNumber(phoneController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> editPassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'New Password',
            ),
            obscureText: true,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                changePassword(passwordController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> changeProfilePicture(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: Container(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: profilePictures.map((picturePath) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(picturePath),
                  ),
                  title: Text(picturePath.split('/').last),
                  onTap: () {
                    saveProfilePicture(picturePath);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
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
}
