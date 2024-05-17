import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/gamification/badge_class.dart';

class NumberGuessingGame extends StatefulWidget {
  const NumberGuessingGame({super.key});

  @override
  State<NumberGuessingGame> createState() => _NumberGuessingGameState();
}

class _NumberGuessingGameState extends State<NumberGuessingGame> {
  final TextEditingController _controller = TextEditingController();
  final int _targetNumber = 7; // The correct number to guess
  bool _badgeAwarded = false;
  bool isLoader = false;

  final Badges _badges = Badges(); // Create an instance of Badges

  Future<void> _checkGuess() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a number')),
      );
      return;
    }

    int guess = int.parse(_controller.text);
    if (guess == _targetNumber) {
      setState(() {
        _badgeAwarded = true;
        isLoader = true;
      });
      await _badges.awardBadge("test2", context); // Use the Badges class
      setState(() {
        isLoader = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try again!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Guess the Number",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter your guess',
            border: OutlineInputBorder(),
            hintText: 'Enter a number',
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (!isLoader) {
                _checkGuess();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: isLoader
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Submit Guess'),
          ),
        ),
        if (_badgeAwarded) ...[
          const SizedBox(height: 20),
          const Text('Congratulations! You have been awarded a badge.'),
        ],
      ],
    );
  }
}
