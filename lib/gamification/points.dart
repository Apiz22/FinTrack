class Points {
  static const int pointsLimit_502030 = 2000;
  static const int pointsLimit_8020 = 1000;
  int calculatePoints(String budgetRule, double expenses, double calbudget) {
    int points = 0;

    switch (budgetRule) {
      case '50/30/20':
        points = calculatePointsForBudget(
          expenses,
          calbudget,
        );
        break;
      case '80/20':
        points = calculatePointsForBudget(expenses, calbudget);
        break;
      default:
        // Handle other cases or throw an error
        break;
    }

    return points;
  }

  int calculatePointsForBudget(double expenses, double calbudget) {
    double percentageSpent = (expenses / calbudget) * 100;
    int points = 0;

    if (percentageSpent > 100) {
      points -= 10; // Deduct points if overspend
    } else {
      // Add points proportionally to the budget, capped at the points limit
      points += (10 * (calbudget / calbudget)).toInt();
      // points = (points > pointsLimit) ? pointsLimit : points;
    }

    return points;
  }
}
