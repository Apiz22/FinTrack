import 'package:flutter/material.dart';

class RankPage extends StatelessWidget {
  const RankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ranking page"),
        backgroundColor: Colors.green,
      ),
      body: Text("rank page"),
    );
  }
}
