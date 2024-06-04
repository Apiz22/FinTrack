import 'package:flutter/material.dart';

import '../gamification/class/badge_class.dart';
import '../gamification/leaderboard.dart';
import '../gamification/test_badges.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => RankPageState();
}

class RankPageState extends State<RankPage> {
  // Instance of Badges class
  final Badges badges = Badges();
  int totalBadgesObtained = 0;

  @override
  void initState() {
    super.initState();
    totalBadges();
  }

  void totalBadges() async {
    int badgesCount = await badges.retrieveTotalBadge();
    setState(() {
      totalBadgesObtained = badgesCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ranking page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade500,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "User Current Badges: $totalBadgesObtained",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const Leaderboard(),
                const NumberGuessingGame(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
