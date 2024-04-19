import 'package:flutter/material.dart';

class note extends StatelessWidget {
  const note({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "**NOTE \n saving** can determine the group of calculation into not achived or not, 80/20 or 50/30/20",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
