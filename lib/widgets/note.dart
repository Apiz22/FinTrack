import 'package:flutter/material.dart';

class Note extends StatelessWidget {
  const Note({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "**NOTE \n pts** can determine the group of calculation into not achived or not, 80/20 (1000pts)or 50/30/20(2000pts) ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("\nCheck point calculation logic+ refine the user page \n fix UI")
      ],
    );
  }
}
