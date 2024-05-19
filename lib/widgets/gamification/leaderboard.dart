import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  String _selectedCategory = '50/30/20';

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

      final List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['username'] ?? 'Unknown',
          'totalBadges': data['totalBadgesObtained'] ?? 0,
        };
      }).toList();

      users.sort((a, b) => b['totalBadges'].compareTo(a['totalBadges']));
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

  Future<void> updateUserRankings(List<Map<String, dynamic>> users) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < users.length; i++) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(users[i]['id']);
      batch.update(userRef, {'currentRanking': i + 1});
    }
    await batch.commit();
  }

  String maskUsername(String username) {
    if (username.length <= 2) {
      return username; // Not enough characters to mask
    }
    return username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
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
                        maskUsername(_users[index]['name']),
                        style: const TextStyle(fontSize: 20),
                      ),
                      trailing: Text(
                        '${_users[index]['totalBadges']} pts',
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
