import 'package:FinTrack/widgets/timeline_month.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryHistory extends StatefulWidget {
  const SummaryHistory({super.key});

  @override
  State<SummaryHistory> createState() => _SummaryHistoryState();
}

class _SummaryHistoryState extends State<SummaryHistory> {
  var monthYear = "";

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthYear = DateFormat("MMM y").format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          TimeLineMonth(onChanged: ((String? value) {
            if (value != null) {
              setState(() {
                monthYear = value;
              });
            }
          })),
          SummaryRecord(selectMonth: monthYear),
        ],
      ),
    );
  }
}

class SummaryRecord extends StatelessWidget {
  final String selectMonth;
  final String userId;

  SummaryRecord({
    super.key,
    required this.selectMonth,
  }) : userId = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>?> fetchMonthlyData() async {
    DocumentSnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("monthly_income")
        .doc(selectMonth)
        .get();

    DocumentSnapshot pointsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("point_history")
        .doc(selectMonth)
        .get();

    if (incomeSnapshot.exists || pointsSnapshot.exists) {
      Map<String, dynamic> mergedData = {};
      if (incomeSnapshot.exists) {
        mergedData.addAll(incomeSnapshot.data() as Map<String, dynamic>);
      }
      if (pointsSnapshot.exists) {
        mergedData.addAll(pointsSnapshot.data() as Map<String, dynamic>);
      }
      return mergedData;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchMonthlyData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'No data available for $selectMonth',
            style: TextStyle(fontSize: 18),
          );
        } else {
          Map<String, dynamic> data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    color: Colors.teal.shade900,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Income & Points Data for $selectMonth',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.containsKey('budgetRule'))
                          Text(
                            'Budget Rule: ${data['budgetRule']}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        if (data.containsKey('currentLevel'))
                          Text(
                            'User Level: ${data['currentLevel']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('totalIncome'))
                          Text(
                            'Total Income: RM ${data['totalIncome'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('remainAmount'))
                          Text(
                            'Remain Amount: RM ${data['remainAmount'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('needs'))
                          Text(
                            'Needs: RM ${data['needs'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('wants'))
                          Text(
                            'Wants: RM ${data['wants'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('savings'))
                          Text(
                            'Savings: RM ${data['savings'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('level'))
                          Text(
                            'Level: ${data['level']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('CurrentPoints'))
                          Text(
                            'Overall points: ${data['CurrentPoints']} pts',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('PtsSavings'))
                          Text(
                            'Savings points: ${data['PtsSavings']} pts',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('currentRanking'))
                          Text(
                            'Ranking for overall: No. ${data['currentRanking']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('currentRankingSaving'))
                          Text(
                            'Saving Ranking: No. ${data['currentRankingSaving']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data['budgetRule'] == "80/20")
                          Text(
                            'Needs & Wants: RM ${(data['needs'] + data['wants']).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
