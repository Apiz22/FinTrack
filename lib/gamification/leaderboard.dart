import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => LeaderboardState();
}

DateTime date = DateTime.now();
String monthyear = DateFormat("MMM y").format(date);

class LeaderboardState extends State<Leaderboard> {
  String selectedCategory = '50/30/20';

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
          final currentPoints = pointsData['CurrentPoints'] ?? 0;
          if (currentPoints > 0) {
            users.add({
              'id': userId,
              'name': data['username'] ?? 'Unknown',
              'currentPoints': currentPoints,
            });
          }
        }
      }

      users.sort((a, b) => b['currentPoints'].compareTo(a['currentPoints']));

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
                      color = Colors.amber;
                      break;
                    case 1:
                      color = Colors.grey;
                      break;
                    case 2:
                      color = Colors.brown;
                      break;
                    default:
                      color = Colors.white;
                  }
                  return Container(
                    color: color,
                    child: ListTile(
                      leading: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        _users[index]['name'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      trailing: Text(
                        '${_users[index]['currentPoints']} points',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
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

    batch.update(userRef, {'currentRanking': i + 1});
    batch.update(pointHistoryRef, {'currentRanking': i + 1});
  }
  await batch.commit();
}

String maskUsername(String username) {
  if (username.length <= 2) {
    return username;
  }
  return username[0] +
      '*' * (username.length - 2) +
      username[username.length - 1];
}
