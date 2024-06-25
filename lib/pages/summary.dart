import 'package:FinTrack/widgets/timeline_month.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SummaryHistory extends StatefulWidget {
  final String userId;
  final String currentMonth;

  const SummaryHistory(
      {super.key, required this.userId, required this.currentMonth});

  @override
  State<SummaryHistory> createState() => _SummaryHistoryState();
}

class _SummaryHistoryState extends State<SummaryHistory> {
  late String monthYear;

  @override
  void initState() {
    super.initState();
    setState(() {
      monthYear = widget.currentMonth;
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
          SummaryRecord(selectMonth: monthYear, userId: widget.userId),
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
    required this.userId,
  });

  Stream<Map<String, dynamic>> fetchMonthlyDataStream() {
    final incomeStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("monthly_income")
        .doc(selectMonth)
        .snapshots();

    final pointsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("point_history")
        .doc(selectMonth)
        .snapshots();

    return Rx.combineLatest2<DocumentSnapshot, DocumentSnapshot,
        Map<String, dynamic>>(
      incomeStream,
      pointsStream,
      (incomeSnapshot, pointsSnapshot) {
        Map<String, dynamic> mergedData = {};
        if (incomeSnapshot.exists) {
          mergedData.addAll(incomeSnapshot.data() as Map<String, dynamic>);
        }
        if (pointsSnapshot.exists) {
          mergedData.addAll(pointsSnapshot.data() as Map<String, dynamic>);
        }
        return mergedData;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: fetchMonthlyDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.containsKey('budgetRule'))
                          Text(
                            'Budget Rule: ${data['budgetRule'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        if (data.containsKey('currentLevel'))
                          Text(
                            'User Level: ${data['currentLevel'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('totalIncome'))
                          Text(
                            'Total Income: RM ${(data['totalIncome'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('remainAmount'))
                          Text(
                            'Remain Amount: RM ${(data['remainAmount'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('needs') &&
                            data['budgetRule'] == "50/30/20")
                          Text(
                            'Needs: RM ${(data['needs'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('wants') &&
                            data['budgetRule'] == "50/30/20")
                          Text(
                            'Wants: RM ${(data['wants'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data['budgetRule'] == "80/20")
                          Text(
                            'Needs & Wants: RM ${((data['needs'] ?? 0) + (data['wants'] ?? 0)).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('savings'))
                          Text(
                            'Savings: RM ${(data['savings'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('level'))
                          Text(
                            'Level: ${data['level'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('CurrentPoints'))
                          Text(
                            'Overall points: ${data['CurrentPoints'] ?? 0} pts',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('PtsSavings'))
                          Text(
                            'Savings points: ${data['PtsSavings'] ?? 0} pts',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('currentRanking') &&
                            data.containsKey('totalUserRanking'))
                          Text(
                            'Ranking for overall: No. ${data['currentRanking'] ?? 0} / ${data['totalUserRanking'] ?? 0}',
                            style: TextStyle(fontSize: 18),
                          ),
                        if (data.containsKey('currentRankingSaving') &&
                            data.containsKey('totalUserSavings'))
                          Text(
                            'Saving Ranking: No. ${data['currentRankingSaving'] ?? 0} / ${data['totalUserSavings'] ?? 0}',
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
