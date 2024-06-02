import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/category_scroll.dart';
import '../widgets/tabbar_view.dart';
import '../widgets/timeline_month.dart';
import '../widgets/transaction_card.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  var category = "All";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expenses page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade500,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          TimeLineMonth(
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  monthYear = value;
                });
              }
            },
          ),
          CategoryList(
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  category = value;
                });
              }
            },
          ),
          TypeTabBar(
            category: category,
            monthYear: monthYear,
          ),
          const TransactionsCard(),
        ]),
      ),
    );
  }
}
