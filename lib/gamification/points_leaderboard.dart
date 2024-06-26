import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PointsLeaderboard extends StatefulWidget {
  const PointsLeaderboard({super.key});

  @override
  State<PointsLeaderboard> createState() => PointsLeaderboardState();
}

DateTime date = DateTime.now();
String monthyear = DateFormat("MMM y").format(date);

class PointsLeaderboardState extends State<PointsLeaderboard> {
  String selectedCategory = '80/20';
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<Map<String, dynamic>> users = [];
      Map<String, dynamic>? currentUser;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userId = doc.id;

        final pointsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('point_history')
            .doc(monthyear)
            .get();

        if (pointsSnapshot.exists) {
          final pointsData = pointsSnapshot.data()!;
          final currentPoints = pointsData['CurrentPoints'] ?? 0;
          final budgetRule = pointsData['budgetRule'];
          final profilePicture = data['profilePicture'] ?? '';

          if (currentPoints > 0 && budgetRule == selectedCategory) {
            Map<String, dynamic> user = {
              'id': userId,
              'name': data['username'] ?? 'Unknown',
              'profilePicture': profilePicture,
              'currentPoints': currentPoints,
            };
            users.add(user);
            if (userId == currentUserId) {
              currentUser = user;
            }
          }
        }
      }

      users.sort((a, b) => b['currentPoints'].compareTo(a['currentPoints']));

      setState(() {
        _users = users;
        _isLoading = false;
        _currentUser = currentUser;
      });

      updateUserRankings(users);
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // String calculateDaysRemaining() {
  //   final firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
  //   final difference = firstDayNextMonth.difference(date).inDays;
  //   return difference.toString();
  // }

  @override
  Widget build(BuildContext context) {
    int currentUserRank =
        _users.indexWhere((user) => user['id'] == currentUserId) + 1;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.teal.shade100,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal.shade400,
              border: Border(bottom: BorderSide(color: Colors.black)),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Budget Leaderboard",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //     child: Text(
          //       "Current Rank Date : $monthyear",
          //       style: TextStyle(
          //         color: Colors.teal.shade500,
          //         fontSize: 23,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
          // Text(
          //   "Days until next reset: ${calculateDaysRemaining()} days",
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontStyle: FontStyle.italic,
          //     color: Colors.teal.shade600,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                      fetchUsers();
                    });
                  }
                },
                items: <String>['50/30/20', '80/20']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.teal.shade400,
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.teal.shade400),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Ranking",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    "User",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Points",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // color: Colors.teal.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length > 10 ? 10 : _users.length,
                      itemBuilder: (context, index) {
                        Color color;
                        switch (index) {
                          case 0:
                            color = Color.fromARGB(255, 255, 224, 22);
                            break;
                          case 1:
                            color = Color.fromARGB(255, 211, 211, 211);
                            break;
                          case 2:
                            color = Color.fromARGB(255, 220, 131, 104);
                            break;
                          default:
                            color = Colors.white;
                        }
                        return Container(
                          color: Colors.teal.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(5),
                              child: UserTile(
                                rank: index + 1,
                                user: _users[index],
                                isCurrentUser:
                                    _users[index]['id'] == currentUserId,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (currentUserRank > 10)
                      Container(
                        color: Colors.teal.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(5),
                            child: UserTile(
                              rank: currentUserRank,
                              user: _currentUser!,
                              isCurrentUser: true,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;
  final bool isCurrentUser;

  const UserTile(
      {required this.rank, required this.user, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '#$rank',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    user['profilePicture'] ?? 'assets/img/default.png',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                isCurrentUser ? 'You' : '${user['name']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      isCurrentUser ? FontWeight.w900 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '${user['currentPoints']} Pts',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 20,
              fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> updateUserRankings(List<Map<String, dynamic>> users) async {
  final batch = FirebaseFirestore.instance.batch();
  for (int i = 0; i < users.length; i++) {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(users[i]['id']);
    final pointHistoryRef = userRef.collection('point_history').doc(monthyear);

    // batch.update(userRef, {'currentRanking': i + 1});
    batch.update(pointHistoryRef, {'currentRanking': i + 1});
    batch.update(pointHistoryRef, {'totalUserRanking': users.length});
  }
  await batch.commit();
}
