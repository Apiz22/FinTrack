import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  var isLogOut = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  bool incomeDialogShown = false; // Flag to track if the dialog has been shown

  logOut() async {
    setState(() {
      isLogOut = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLogOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date
    // DateTime now = DateTime.now();

    // // Check if the current date is the 17th day of the month
    // bool isSeventeenthDay = now.day == 17 && !incomeDialogShown;

    // // Show a dialog if it's the 17th day of the month
    // if (isSeventeenthDay) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     _showDialog();
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text("user Page"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: isLogOut
                ? const CircularProgressIndicator()
                : const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Text("user"),
    );
  }

  // Function to show the dialog
  // void _showDialog() {
  //   TextEditingController incomeController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Insert Income'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: incomeController,
  //               keyboardType: TextInputType.number,
  //               decoration: InputDecoration(
  //                 labelText: 'Enter Income',
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Get the entered income value
  //               String income = incomeController.text;

  //               // Validate the input (optional)

  //               // Save the income to Firebase
  //               _saveIncomeToFirebase(income);

  //               // Set the flag to true to indicate that the dialog has been shown
  //               setState(() {
  //                 incomeDialogShown = true;
  //               });

  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _saveIncomeToFirebase(String income) {
  //   // Access Firebase and save the income data
  //   FirebaseFirestore.instance.collection('users').doc(userId).update({
  //     'remainAmount': income,
  //   }).then((value) {
  //     // Handle success
  //     print('Income saved successfully!');
  //   }).catchError((error) {
  //     // Handle error
  //     print('Failed to save income: $error');
  //   });
  // }
}
