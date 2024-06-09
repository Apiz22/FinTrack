import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  TransactionList(
      {super.key,
      required this.category,
      required this.type,
      required this.monthYear});

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final String category;
  final String type;
  final String monthYear;

//monthyear
  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("transactions")
        .orderBy('timestamp', descending: true)
        .where("monthyear", isEqualTo: monthYear)
        .where("type", isEqualTo: type);

    if (category != 'All') {
      query = query.where("category", isEqualTo: category);
    }

    return FutureBuilder<QuerySnapshot>(
        future: query.limit(150).get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text("No transactions found");
          }

          var data = snapshot.data!.docs;

          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  data.length, // Set the number of items you want to display
              itemBuilder: (context, index) {
                var cardInt = data[index];
                return TransactionItem(
                  data: cardInt,
                );
              },
            ),
          );
        });
  }

  // Function to calculate dynamic height based on number of transactions
  double calculateHeight(int itemCount) {
    const double itemHeight = 80.0; // Height of each transaction item
    const double minHeight = 100.0; // Minimum height when no transactions
    const double maxContainerHeight = 400.0; // Maximum container height

    // Calculate height based on number of items
    double calculatedHeight = minHeight + (itemHeight * itemCount);

    // Return calculated height, capped at maxContainerHeight
    return calculatedHeight > maxContainerHeight
        ? maxContainerHeight
        : calculatedHeight;
  }
}
