import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/transaction_Item.dart';
import 'package:intl/intl.dart';

class TransactionsCard extends StatelessWidget {
  TransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Transaction",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10), // Add SizedBox for spacing
          Container(
            height: 500, // Set a fixed height for the ListView
            child: RecentTransactionList(),
          ),
        ],
      ),
    );
  }
}

class RecentTransactionList extends StatelessWidget {
  RecentTransactionList({
    super.key,
  });

  final userId = FirebaseAuth.instance.currentUser!.uid;
  String monthYear = DateFormat("MMM y").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection("transactions")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text("No transactions found");
          }

          var data = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                data.length, // Set the number of items you want to display
            itemBuilder: (context, index) {
              var cardInt = data[index];
              return TransactionItem(
                data: cardInt,
              );
            },
          );
        });
  }
}