import 'package:flutter/material.dart';

import '../pages/add_exp_page.dart';
import '../pages/expenses_page.dart';
import '../pages/home_screen.dart';
import '../pages/rank_page.dart';
import '../pages/user_page.dart';
import '../widgets/nav_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int currentPageIndex = 0;
  // var isLogOut = false;
  var pageViewList = [
    const MainPage(),
    const ExpensesPage(),
    const AddExpPage(),
    const RankPage(),
    const UserPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: pageViewList[currentPageIndex],
      // body: _buildBody(currentPageIndex),
    );
  }
}
