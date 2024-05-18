import 'package:flutter/material.dart';
import 'package:ft_v2/widgets/transaction_list.dart';

class TypeTabBar extends StatelessWidget {
  const TypeTabBar(
      {super.key, required this.category, required this.monthYear});

  final String category;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [
            Tab(
              text: ("Debit"),
            ),
            Tab(
              text: ("Credit"),
            ),
          ]),
          SizedBox(
            height: 500,
            child: TabBarView(children: [
              TransactionList(
                category: category,
                type: "debit",
                monthYear: monthYear,
              ),
              TransactionList(
                category: category,
                type: "credit",
                monthYear: monthYear,
              ),
            ]),
          )
        ],
      ),
    );
  }
}
