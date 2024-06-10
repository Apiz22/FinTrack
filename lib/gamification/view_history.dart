import 'package:FinTrack/widgets/timeline_month.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewHistory extends StatefulWidget {
  final String userId;
  const ViewHistory({super.key, required this.userId});

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  Map<String, Map<String, dynamic>>? allIncomeData;
  Map<String, Map<String, dynamic>>? allExpensesData;
  String? selectedMonth;

  var monthYear = "";

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      selectedMonth = DateFormat("MMM y").format(now);
      monthYear = DateFormat("MMM y").format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            color: Colors.teal.shade900,
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Text(
              "Expenses Record Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<Map<String, Map<String, Map<String, dynamic>>>>(
            future: _fetchAllData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data available.');
              } else {
                allIncomeData = snapshot.data!['income'];
                allExpensesData = snapshot.data!['expenses'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TimeLineMonth(
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            monthYear = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    ...[
                      IncomeDataWidget(incomeData: allIncomeData?[monthYear]),
                      SizedBox(height: 20),
                      ExpensesDataWidget(
                          expensesData: allExpensesData?[monthYear]),
                    ],
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, Map<String, Map<String, dynamic>>>> _fetchAllData() async {
    QuerySnapshot incomeSnapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('monthly_income')
        .get();

    QuerySnapshot expensesSnapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('expenses_record')
        .get();

    Map<String, Map<String, dynamic>> incomeData = {};
    Map<String, Map<String, dynamic>> expensesData = {};

    for (var doc in incomeSnapshots.docs) {
      incomeData[doc.id] = doc.data() as Map<String, dynamic>;
    }

    for (var doc in expensesSnapshots.docs) {
      expensesData[doc.id] = doc.data() as Map<String, dynamic>;
    }

    return {'income': incomeData, 'expenses': expensesData};
  }
}

class IncomeDataWidget extends StatelessWidget {
  final Map<String, dynamic>? incomeData;

  const IncomeDataWidget({super.key, required this.incomeData});

  @override
  Widget build(BuildContext context) {
    if (incomeData == null) {
      return Text("No income data available.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text('Total Income: ${incomeData!['totalIncome']}'),
        Text('Remain Amount: ${incomeData!['remainAmount']}'),
        Text('Needs: ${incomeData!['needs']}'),
        Text('Wants: ${incomeData!['wants']}'),
        Text('Savings: ${incomeData!['savings']}'),
      ],
    );
  }
}

class ExpensesDataWidget extends StatelessWidget {
  final Map<String, dynamic>? expensesData;

  const ExpensesDataWidget({super.key, required this.expensesData});

  @override
  Widget build(BuildContext context) {
    if (expensesData == null) {
      return Text("No expenses data available.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expenses Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text('Level: ${expensesData!['Level']}'),
        Text('Total Income: ${expensesData!['Total Income']}'),
        Text('Budget Rule: ${expensesData!['budgetRule']}'),
        // Uncomment the following lines if needed
        // Text('Savings Points: ${expensesData!['SavingsPoints']}'),
        // Text('Wants Points: ${expensesData!['WantsPoints']}'),
        // Text('Current Ranking Saving: ${expensesData!['currentRankingSaving']}'),
      ],
    );
  }
}
