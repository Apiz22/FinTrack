import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/transaction_Item.dart';

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
