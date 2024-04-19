import 'package:flutter/material.dart';
import 'package:ft_v2/pages/add_exp.dart';
import 'package:ft_v2/pages/expenses.dart';
import 'package:ft_v2/pages/home_screen.dart';
import 'package:ft_v2/pages/rank.dart';
import 'package:ft_v2/pages/user_page.dart';
import 'package:ft_v2/widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // Widget _buildBody(int index) {
  //   switch (index) {
  //     case 0:
  //       return const MainPage(); // Return MainPage widget
  //     case 1:
  //       return const ExpensesPage();
  //     case 2:
  //       return const AddExpPage();
  //     case 3:
  //       return const RankPage();
  //     case 4:
  //       return const UserPage(); // Return UserPage widget
  //     default:
  //       return Container(); // Return an empty container if index is invalid
  //   }
  // }
}
