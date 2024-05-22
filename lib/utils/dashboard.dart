import 'package:flutter/material.dart';
import 'package:ft_v2/pages/add_exp_page.dart';
import 'package:ft_v2/pages/expenses_page.dart';
import 'package:ft_v2/pages/home_screen.dart';
import 'package:ft_v2/pages/rank_page.dart';
import 'package:ft_v2/pages/user_page.dart';
import 'package:ft_v2/widgets/nav_bar.dart';

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
