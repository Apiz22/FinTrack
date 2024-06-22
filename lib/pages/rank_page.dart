import 'package:FinTrack/gamification/saving_leaderboard.dart';
import 'package:flutter/material.dart';
import '../gamification/class/badge_class.dart';
import '../gamification/points_leaderboard.dart';
import 'package:intl/intl.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => RankPageState();
}

class RankPageState extends State<RankPage> {
  // Instance of Badges class
  final Badges badges = Badges();

  // State variable to track the current leaderboard
  bool showPointsLeaderboard = true;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonthYear = DateFormat("MMM y").format(now);
    String daysUntilNextReset =
        (DateTime(now.year, now.month + 1, 1).difference(now).inDays)
            .toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ranking page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade900,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showPointsLeaderboard = !showPointsLeaderboard;
                    });
                  },
                  child: Text(
                    showPointsLeaderboard
                        ? "Switch to Saving Leaderboard"
                        : "Switch to Points Leaderboard",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      "Current Rank Month: $currentMonthYear",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Days until next reset: $daysUntilNextReset days",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                showPointsLeaderboard
                    ? const PointsLeaderboard()
                    : const SavingLeaderboard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
