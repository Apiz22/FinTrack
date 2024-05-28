import 'package:flutter/material.dart';
import 'package:ft_v2/gamification/class/badge_class.dart';
import 'package:ft_v2/gamification/leaderboard.dart';
import 'package:ft_v2/gamification/test_badges.dart';

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
        title: const Text("Ranking page"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NumberGuessingGame(),
            Text("User Current Badges: $totalBadgesObtained"),
            const Leaderboard(),
          ],
        ),
      ),
    );
  }
}
