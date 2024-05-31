import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      indicatorColor: Colors.teal.shade500,
      destinations: const <Widget>[
        //NavigationDestination
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
          selectedIcon: Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        NavigationDestination(
          icon: Icon(Icons.money),
          label: 'Expenses',
          selectedIcon: Icon(
            Icons.money,
            color: Colors.white,
          ),
        ),
        NavigationDestination(
          icon: Icon(Icons.add),
          label: 'Add Expenses',
          selectedIcon: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        NavigationDestination(
          icon: Icon(Icons.book),
          label: 'Leaderboard',
          selectedIcon: Icon(
            Icons.book,
            color: Colors.white,
          ),
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'User',
          selectedIcon: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
