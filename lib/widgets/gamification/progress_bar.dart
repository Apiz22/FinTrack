import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    String per100 = (percent * 100).toStringAsFixed(0);

    return CircularPercentIndicator(
      radius: 30,
      lineWidth: 10,
      percent: percent.clamp(0.0, 1.0), // Ensures percent is between 0 and 1,
      progressColor: Colors.green,
      backgroundColor: Colors.green.shade200,
      circularStrokeCap: CircularStrokeCap.round,
      center: Text(
        "$per100%",
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}