import 'package:FinTrack/pages/home_screen.dart';
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

String currentmonthyear = DateFormat("MMM y").format(DateTime.now());

class _UserPageState extends State<UserPage> {
  var isLogOut = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  DateTime date = DateTime.now();
  String? selectedBudgetRule;
  int dayCount = 0;

  // Instance of Badges class
  final Badges badges = Badges();
  final Points points = Points();
  int _totalBadgesObtained = 0;
  int achiveStreak = 0;
  int currentPts = 0;
  String currentLevel = "";
  String currentBudget = "";
  String username = "";
  String profilePicturePath = 'assets/img/Pfps.jpg';

  final List<String> profilePictures = [
    'assets/img/Pfps.jpg',
    'assets/img/default.png',
    'assets/img/pedro.jpeg',
    'assets/img/male1.jpg',
    'assets/img/male2.jpg',
    'assets/img/female1.jpg',
    'assets/img/default.png'
  ];

  Database database = Database();

  @override
  void initState() {
    super.initState();
    totalBadges();
    get_CurrenPts_CurrentBudget_CurrentLvl();
    getUsername();
    getWinStreak();
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
    int badgesCount = await badges.retrieveTotalBadge(currentmonthyear);
    setState(() {
      _totalBadgesObtained = badgesCount;
    });
  }

  void get_CurrenPts_CurrentBudget_CurrentLvl() async {
    int curPts = await points.retrieveCurrentPts(userId);
    String curBud = await points.retrieveCurrentBudgetRule(userId);
    String curLvl = await database.getUserCurrentLevel(userId);
    setState(() {
      currentPts = curPts;
      currentBudget = curBud;
      currentLevel = curLvl;
    });
  }

  void getWinStreak() async {
    int winstreak = await database.getUserWinStreak(userId);
    setState(() {
      achiveStreak = winstreak;
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

  // void changeCurrentRule() async {
  //   if (currentPts >= 2000 && currentBudget == "50/30/20") {
  //     database.saveBudgetRuleToFirebase("50/30/20");
  //   } else if (currentPts <= 1000 && currentBudget == "80/20") {
  //     database.saveBudgetRuleToFirebase("80/20");
  //   } else {
  //     return _showIneligibleDialog(context);
  //   }
  // }

  // void _showIneligibleDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Not Eligible'),
  //         content: Text('You are not eligible to change the rule.'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({'phone': newPhoneNumber});
  }

  // Future<void> changePassword(String newPassword) async {
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(userId)
  //       .update({'password': newPassword});
  // }

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
        child: Column(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(8.0),
            //   margin: const EdgeInsets.symmetric(vertical: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.teal.shade50,
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.teal),
            //   ),
            //   child: Text(
            //     "Current Points: $currentPts",
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // ElevatedButton(
            //   onPressed: changeCurrentRule,
            //   child: const Text("Update Rule based on Points"),
            // ),
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal),
              ),
              child: Text(
                "Total Badges Obtained: $_totalBadgesObtained",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              // color: Colors.amber,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Badges Collections",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  badgesList(),
                ],
              ),
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
            color: Colors.teal.shade200,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(profilePicturePath),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: Text(
                        "Current Points: $currentPts",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
                onChanged:
                    (currentLevel == "Intermediate" || currentLevel == "Expert")
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
                  // enabled: achiveStreak > 0,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: (_totalBadgesObtained > 1)
                  ? () {
                      database.updateNextRuleToFirebase(selectedBudgetRule);
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
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    bool _isCurrentPasswordVisible = false;
    bool _isNewPasswordVisible = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isCurrentPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isCurrentPasswordVisible,
                  ),
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isNewPasswordVisible,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    bool success = await changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );
                    if (success) {
                      Navigator.pop(context);
                    } else {
                      // Show error message if reauthentication fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Current password is incorrect')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (user == null) {
      return false; // User is not logged in
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      // Reauthenticate user with the current password
      await user.reauthenticateWithCredential(credential);

      // Update password after successful reauthentication
      await user.updatePassword(newPassword);

      // Update password in Firestore
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'password': newPassword,
      });

      print('Password updated successfully!');
      return true;
    } catch (e) {
      print('Failed to update password: $e');
      return false;
    }
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
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: profilePictures.map((picturePath) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close the current dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Change Profile Picture'),
                                content: const Text(
                                    'Are you sure you want to change the profile picture?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the confirmation dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      saveProfilePicture(picturePath);
                                      Navigator.pop(
                                          context); // Close the confirmation dialog
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(picturePath),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container badgesList() {
    return Container(
      child: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: badges.retrieveBadgesList(currentmonthyear),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error loading data");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              children: [
                Center(
                    child: const Text(
                        'No badges obtained yet. Try keep track your money expenses and stay stick with the budget')),
              ],
            );
          }
          final badgesList = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badgesList.length,
            itemBuilder: (context, index) {
              final badge = badgesList[index].data() as Map<String, dynamic>;
              final imageUrl = badge['imageUrl'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? Colors.teal.shade200
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
                            : Image.asset(
                                'assets/img/default.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
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
          );
        },
      ),
    );
  }
}
