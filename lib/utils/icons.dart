import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  final List<Map<String, dynamic>> homeExpensesCategories = [
    {
      "name": "Foods & Beverage",
      "icon": FontAwesomeIcons.bowlRice,
    },
    {
      "name": "Utilities",
      "icon": FontAwesomeIcons.wallet,
    },
    {
      "name": "Investment",
      "icon": FontAwesomeIcons.seedling,
    },
    {
      "name": "Entertainment",
      "icon": FontAwesomeIcons.film,
    },
    {
      "name": "Medical",
      "icon": FontAwesomeIcons.pills,
    },
    {
      "name": "Transportation",
      "icon": FontAwesomeIcons.trainTram,
    },
    {
      "name": "Shopping",
      "icon": FontAwesomeIcons.bagShopping,
    },
    {
      "name": "Gas Filling",
      "icon": FontAwesomeIcons.gasPump,
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
