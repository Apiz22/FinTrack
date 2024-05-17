import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/gamification/progress_bar.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.userId, this.currentMonthYear});

  final String userId;
  final currentMonthYear;
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('monthly_income')
        .doc(currentMonthYear)
        .snapshots();

    return Column(
      children: [
        StreamBuilder(
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
            double calNeeds = data["cal_needs"];
            double calWants = data["cal_wants"];
            double calSaving = data["cal_savings"];
            double needs = data["needs"];
            double wants = data["wants"];
            double savings = data["savings"];

            return Column(
              children: [
                const Text(
                  "Your current Budget: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data["budgetRule"]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildRow(context, "Need", calNeeds, needs,
                    "Needs — as you may gathered — are the things that you absolutely cannot do without. They are those goods and services that you must have to lead a decent life. The most common needs are air, food, water, clothing and shelter. Without these basic necessities, your life may be extremely challenging or downright hard."),
                _buildRow(context, "Wants", calWants, wants,
                    "Wants, or discretionary expenses, are the things that you don’t really need. They are the costs of the products and services that you would like to have. If it comes down to it, you can eliminate all the wants or inessential expenses from your budget and still lead a fairly comfortable life."),
                _buildRow(context, "Savings", calSaving, savings,
                    "Savings are kept in the form of cash or cash equivalents (e.g. as bank deposits), which are exposed to no risk of loss but also come with correspondingly minimal returns."),
              ],
            );
          },
        ),
      ],
    );
  }
}

Widget _buildRow(BuildContext context, String header, double calAmount,
    double amount, String description) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Row(
      children: [
        budgetCategory(header, calAmount, amount),
        IconButton(
          //info budget
          icon: const Icon(Icons.info),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(header),
                  content: SingleChildScrollView(
                    child: Text(description),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

Expanded budgetCategory(String header, double calAmount, double amount) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 138, 138, 138),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "RM $amount / $calAmount",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            ProgressBar(
              percent: amount / calAmount,
            ),
          ],
        ),
      ),
    ),
  );
}
