
class Points {
  static const int pointsLimit502030 = 2000;
  static const int pointsLimit8020 = 1000;
  int calculatePoints(String budgetRule, double amount, double expenses,
      double calbudget, double income, String category, double combine) {
    int points = 0;
    double combineNeedsSavings = income * 0.8;
    int weight = 0;

    switch (budgetRule) {
      case '50/30/20':
        if (category == "needs") {
          int weight = 50;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        } else if (category == "wants") {
          weight = 20;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        } else {
          weight = 20;
          points = calculatePointsForBudget(
            amount,
            expenses,
            calbudget,
            weight,
          );
          break;
        }
      case '80/20':
        if (category == "needs" || category == "wants") {
          weight = 80;
          points = calculatePointsForBudget(
              amount, combine, combineNeedsSavings, weight);
          break;
        } else if (category == "savings") {
          weight = 20;
          points =
              calculatePointsForBudget(amount, expenses, calbudget, weight);
          break;
        }

      default:
        // Handle other cases or throw an error
        break;
    }

    return points;
  }

  int calculatePointsForBudget(
      double amount, double expenses, double calbudget, int weight) {
    double percentageSpent = (expenses / calbudget) * 100;
    int calPoints = 0;

    if (percentageSpent > 100) {
      calPoints -= amount.toInt(); // Deduct points if overspend
    } else {
      // calPoints += (amount).toInt();

      calPoints = (10 * ((amount / calbudget) * weight)).toInt();

      // calPoints = (calPoints > pointsLimit) ? pointsLimit : calPoints;
    }

    return calPoints;
  }
}
