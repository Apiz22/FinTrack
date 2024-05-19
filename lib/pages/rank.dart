import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/gamification/badge_class.dart';
import 'package:ft_v2/widgets/gamification/leaderboard.dart';
import 'package:ft_v2/widgets/gamification/test_badges.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => RankPageState();
}

class RankPageState extends State<RankPage> {
  // Instance of Badges class
  final Badges badges = Badges();

  @override
  void initState() {
    super.initState();
    totalBadges();
  }

  void totalBadges() async {
    await badges.retriveTotalBadge();
    setState(() {}); // This will rebuild the widget to reflect any changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ranking page"),
        backgroundColor: Colors.green,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            NumberGuessingGame(),
            Text("leaderboard"),
            Text("User Current Rank:"),
            Leaderboard(),
          ],
        ),
      ),
    );
  }
}
