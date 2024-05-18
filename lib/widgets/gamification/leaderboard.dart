import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  String _selectedCategory = '50/30/20';
  List<Map<String, dynamic>> _users = [
    {'name': 'Alice', 'points': 100},
    {'name': 'Bob', 'points': 950},
    {'name': 'Charlie', 'points': 900},
    {'name': 'David', 'points': 850},
    {'name': 'Eve', 'points': 800},
    {'name': 'Frank', 'points': 750},
    {'name': 'Grace', 'points': 700},
    {'name': 'Heidi', 'points': 1000},
    {'name': 'Ivan', 'points': 600},
    {'name': 'Judy', 'points': 550},
    {'name': 'Borhan', 'points': 5550},
  ];

  @override
  void initState() {
    super.initState();
    _sortUsers();
  }

  void _sortUsers() {
    _users.sort((a, b) => b['points'].compareTo(a['points']));
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
              setState(() {
                _selectedCategory = newValue!;
                // Assuming you may want to change the sorting or users based on category
                _sortUsers();
              });
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _users.length,
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
                  '${_users[index]['points']} pts',
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
