import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/view_card.dart';

class budgetCard extends StatelessWidget {
  const budgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(context, "Needs", "10",
            "Needs — as you may gathered — are the things that you absolutely cannot do without. They are those goods and services that you must have to lead a decent life. The most common needs are air, food, water, clothing and shelter. Without these basic necessities, your life may be extremely challenging or downright hard."),
        _buildRow(context, "Wants", "10",
            "Wants, or discretionary expenses, are the things that you don’t really need. They are the costs of the products and services that you would like to have. If it comes down to it, you can eliminate all the wants or inessential expenses from your budget and still lead a fairly comfortable life."),
        _buildRow(context, "Savings", "10",
            "Savings are kept in the form of cash or cash equivalents (e.g. as bank deposits), which are exposed to no risk of loss but also come with correspondingly minimal returns."),
      ],
    );
  }

  Widget _buildRow(
      BuildContext context, String header, String amount, String description) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          BudgetCategory(header),
          IconButton(
            //info budget
            icon: Icon(Icons.info),
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
                        child: Text('Close'),
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

  Expanded BudgetCategory(String header) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "RM 10",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
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
