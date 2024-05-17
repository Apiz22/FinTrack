import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/gamification/test_badges.dart';

class RankPage extends StatelessWidget {
  const RankPage({super.key});

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
            Text("Rank page"),
            NumberGuessingGame(),
          ],
        ),
      ),
    );
  }
}
