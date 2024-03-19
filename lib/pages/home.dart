import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLogOut = false;
  logOut() async {
    setState(() {
      isLogOut = false;
    });
    await FirebaseAuth.instance.signOut();

    setState(() {
      isLogOut = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                logOut();
              },
              icon: isLogOut
                  ? CircularProgressIndicator()
                  : Icon(Icons.exit_to_app))
        ],
      ),
      body: Text("hello world"),
    );
  }
}
