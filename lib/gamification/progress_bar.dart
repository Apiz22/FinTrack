import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar(
      {super.key, required this.percent, required this.onComplete});

  final double percent;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    String per100 = (percent * 100).toStringAsFixed(1);

    if (percent >= 1.0) {
      // If percent is 100%, call the onComplete callback
      onComplete();
    }

    return CircularPercentIndicator(
      radius: 30,
      lineWidth: 10,
      percent: percent.clamp(0.0, 1.0), // Ensures percent is between 0 and 1,
      progressColor: percent > 1.0 ? Colors.amber.shade800 : Colors.teal,
      backgroundColor: Colors.white70,
      circularStrokeCap: CircularStrokeCap.round,
      center: Text(
        "$per100%",
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}
