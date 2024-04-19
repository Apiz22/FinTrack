import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopSplit extends StatelessWidget {
  TopSplit({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> _usersStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: _usersStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Data not available');
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return TotalCard(
          data: data,
        );
      },
    );
  }
}

class TotalCard extends StatelessWidget {
  const TotalCard({
    super.key,
    required this.data,
  });

  final Map data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Balance",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "RM ${data["remainAmount"]}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
        Container(
          padding: EdgeInsets.all(5),
          // EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(30),
            //   topRight: Radius.circular(30),
            // ),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Row(
            children: [
              OneCard(
                color: Colors.green,
                header: 'Credit',
                amount: '${data["totalCredit"]}',
              ),
              SizedBox(
                width: 10,
              ),
              OneCard(
                color: Colors.amber,
                header: 'Debit',
                amount: '${data["totalDebit"]}',
              ),
            ],
          ),
        )
      ],
    );
  }
}

class OneCard extends StatelessWidget {
  const OneCard({
    super.key,
    required this.color,
    required this.header,
    required this.amount,
  });

  final Color color;
  final String header;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "RM ${amount}",
                    style: TextStyle(
                      color: color,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  header == "Credit"
                      ? Icons.arrow_upward_outlined
                      : Icons.arrow_downward,
                  color: color,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
