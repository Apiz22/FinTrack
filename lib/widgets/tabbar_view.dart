import 'package:flutter/material.dart';

import 'transaction_list.dart';

class TypeTabBar extends StatefulWidget {
  const TypeTabBar(
      {super.key, required this.category, required this.monthYear});

  final String category;
  final String monthYear;

  @override
  State<TypeTabBar> createState() => _TypeTabBarState();
}

class _TypeTabBarState extends State<TypeTabBar> {
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
            height: 300,
            child: TabBarView(children: [
              TransactionList(
                category: widget.category,
                type: "debit",
                monthYear: widget.monthYear,
              ),
              TransactionList(
                category: widget.category,
                type: "credit",
                monthYear: widget.monthYear,
              ),
            ]),
          )
        ],
      ),
    );
  }
}
