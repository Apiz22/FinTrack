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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("Expenses Record"),
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchPreviousIncomeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No previous income data available.');
              } else {
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Month Income',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Total Income: ${data['totalIncome']}'),
                    Text('Remain Amount: ${data['remainAmount']}'),
                    Text('Needs: ${data['needs']}'),
                    Text('Wants: ${data['wants']}'),
                    Text('Savings: ${data['savings']}'),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchPreviousIncomeData() async {
    DateTime date = DateTime.now();
    DateTime previousDate = DateTime(date.year, date.month - 1, date.day);
    String previousIncomeDate = DateFormat("MMM y").format(previousDate);

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('monthly_income')
        .doc(previousIncomeDate)
        .get();

    return docSnapshot.exists ? docSnapshot.data() : null;
  }
}
