import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopSplit extends StatelessWidget {
  const TopSplit({
    super.key,
    required this.userId,
    required this.monthYear,
  });

  final String userId;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_income')
        .doc(monthYear)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: usersStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Data not available');
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return TotalCard(
          data: data,
        );
      },
    );
  }
}

//Display the Total Balance , Credit, Debit
class TotalCard extends StatelessWidget {
  const TotalCard({
    super.key,
    required this.data,
  });

  final Map data;

//Display the Total Balance
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Total Balance",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "RM ${data["remainAmount"].toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        //Display Credit and Debit
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 242, 234, 234),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Row(
            children: [
              OneCard(
                color: Colors.green,
                header: 'Credit',
                amount: '${data["totalCredit"].toStringAsFixed(2)}',
              ),
              const SizedBox(
                width: 5,
              ),
              OneCard(
                color: Colors.amber,
                header: 'Debit',
                amount: '${data["totalDebit"].toStringAsFixed(2)}',
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
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        header,
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Icon(
                        header == "Credit"
                            ? Icons.arrow_upward_outlined
                            : Icons.arrow_downward,
                        color: color,
                      ),
                    ],
                  ),
                  Text(
                    "RM $amount",
                    style: TextStyle(
                      color: color,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
