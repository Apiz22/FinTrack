import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/budget_card.dart';
import 'package:ft_v2/widgets/note.dart';
import 'package:ft_v2/widgets/view_card.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Widget build(BuildContext context) {
    String currentDate = DateFormat("dd MMMM").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FinTrack",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[400],
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentDate,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TopSplit(
                  userId: userId,
                ),
              ),
            ),
            SizedBox(),
            Container(
              padding: EdgeInsets.all(10),
              color: const Color.fromARGB(255, 199, 124, 124),
              child: const Column(
                children: [
                  note(),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            //Expenses breakdown
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Column(
                children: [
                  Text("Expenses breakdown"),
                  budgetCard(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
