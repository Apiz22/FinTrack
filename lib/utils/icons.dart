import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  final List<Map<String, dynamic>> homeExpensesCategories = [
    {
      "name": "Gas Filling",
      "icon": FontAwesomeIcons.gasPump,
    },
    {
      "name": "Internet",
      "icon": FontAwesomeIcons.wifi,
    },
    {
      "name": "Needs", // Changed from "needs" to "Needs" for uniqueness
      "icon": FontAwesomeIcons.wallet,
    },
    {
      "name": "Wants", // Changed from "needs" to "Needs" for uniqueness
      "icon": FontAwesomeIcons.wallet,
    },
    {
      "name": "Savings", // Changed from "needs" to "Needs" for uniqueness
      "icon": FontAwesomeIcons.wallet,
    },
    {
      "name": "Others",
      "icon": FontAwesomeIcons.cartPlus,
    },
  ];

  IconData getExpenseCategoryIcons(String categoryName) {
    final category = homeExpensesCategories.firstWhere(
        (category) => category['name'] == categoryName,
        orElse: () => {"icon": FontAwesomeIcons.cartShopping} // Default icon
        );
    return category['icon'];
  }
}
