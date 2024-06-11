import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingLeaderboard extends StatefulWidget {
  const SavingLeaderboard({super.key});

  @override
  State<SavingLeaderboard> createState() => _SavingLeaderboardState();
}

DateTime date = DateTime.now();
String monthyear = DateFormat("MMM y").format(date);

class _SavingLeaderboardState extends State<SavingLeaderboard> {
  String selectedCategory = '80/20';

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

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
          final PtsSavings = pointsData['PtsSavings'] ?? 0;
          final profilePicture = data['profilePicture'] ?? '';

          if (PtsSavings > 0 && PtsSavings < 200) {
            users.add({
              'id': userId,
              'name': data['username'] ?? 'Unknown',
              'profilePicture': profilePicture,
              'PtsSavings': PtsSavings,
            });
          }
        }
      }

      users.sort((a, b) => b['PtsSavings'].compareTo(a['PtsSavings']));

      setState(() {
        _users = users;
        _isLoading = false;
      });

      updateUserRankings(users);
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String calculateDaysRemaining() {
    final firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    final difference = firstDayNextMonth.difference(date).inDays;
    return difference.toString();
  }

  @override
  Widget build(BuildContext context) {
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
              "Saving Leaderboard",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 10,
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
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _users.length > 10 ? 10 : _users.length,
                  itemBuilder: (context, index) {
                    Color color;
                    switch (index) {
                      case 0:
                        color = Color.fromARGB(255, 255, 223, 0);
                        break;
                      case 1:
                        color = Color.fromARGB(255, 192, 192, 192);
                        break;
                      case 2:
                        color = Color.fromARGB(255, 203, 109, 81);
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;

  const UserTile({required this.rank, required this.user});

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
                '${user['name']}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '${user['PtsSavings']} points',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 20),
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

    batch.update(userRef, {'currentRankingSaving': i + 1});
    batch.update(pointHistoryRef, {'currentRankingSaving': i + 1});
  }
  await batch.commit();
}
