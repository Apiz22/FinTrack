import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../gamification/points.dart';
import '../utils/appvalidator.dart';
import '../widgets/category_dropdown.dart';

class AddExpPage extends StatefulWidget {
  const AddExpPage({super.key});

  @override
  State<AddExpPage> createState() => _AddExpPageState();
}

class _AddExpPageState extends State<AddExpPage> {
  var type = "debit";
  var category = ""; // Initialize to an empty string
  var budget = "needs";
  String userLevel = "";
  int savePts = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var isLoader = false;
  var appValidator = AppValidator();
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  var uid = const Uuid();

  final Points points = Points();

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate category selection
      if (appValidator.validateCategory(category) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appValidator.validateCategory(category)!)),
        );
        return;
      }

      setState(() {
        isLoader = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      int timestamp = DateTime.now().microsecondsSinceEpoch;
      var amount = double.parse(amountEditController.text);
      DateTime date = DateTime.now();
      var id = uid.v4();
      String monthyear = DateFormat("MMM y").format(date);

      // Retrieve user current income
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection('monthly_income')
          .doc(monthyear)
          .get();

      double income = userDoc["totalIncome"].toDouble();
      double remainAmount = userDoc["remainAmount"].toDouble();
      double totalCredit = userDoc["totalCredit"].toDouble();
      double totalDebit = userDoc["totalDebit"].toDouble();
      double expNeeds = userDoc["needs"].toDouble();
      double expWants = userDoc["wants"].toDouble();
      double expSavings = userDoc["savings"].toDouble();
      double calNeeds = userDoc["cal_needs"].toDouble();
      double calWants = userDoc["cal_wants"].toDouble();
      double calSavings = userDoc["cal_savings"].toDouble();

      int currentPts = 0;
      int combinePts = 0;

//Retrieve user current points
      final pointsDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection('point_history')
          .doc(monthyear)
          .get();

      int needspts = pointsDoc["NeedsPoints"];
      int wantspts = pointsDoc["WantsPoints"];
      int savingsspts = pointsDoc["SavingsPoints"];
      String budgetRule = pointsDoc["budgetRule"];
      DocumentSnapshot userFile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      int winStreak = userFile["ruleWinStreak"] ?? 0;

      // Calculate expenses amount + pts
      if (type == "credit") {
        remainAmount += amount;
        totalCredit += amount;
      }
      //Debit
      else {
        remainAmount -= amount;
        totalDebit += amount;
        if (budget == "needs") {
          expNeeds += amount;
        } else if (budget == "wants") {
          expWants += amount;
        } else {
          expSavings += amount;
        }

// calculate points
        if (budgetRule == "50/30/20") {
          needspts = points.calculatePointsForBudget(expNeeds, calNeeds, 100);
          wantspts = points.calculatePointsForBudget(expWants, calWants, 60);
          savingsspts =
              points.calculatePointsForBudget(expSavings, calSavings, 40);

          currentPts = needspts + wantspts + savingsspts;
        } //rule == 80/20
        else {
          double combineExp = expNeeds + expWants;
          if (combineExp > (income * 0.8)) {
            double over = combineExp - (income * 0.8);
            combinePts = ((10 * 80) - over).toInt();
          } else {
            combinePts = (10 * ((combineExp / (income * 0.8)) * 80)).toInt();
          }
          savingsspts =
              points.calculatePointsForBudget(expSavings, calSavings, 20);

          currentPts = combinePts + savingsspts;
        }

        if ((currentPts == 1000 && budgetRule == "80/20") ||
            (currentPts == 2000 && budgetRule == "50/30/20")) {
          winStreak += 1;
        } else {
          winStreak = 0;
        }

        savePts = points.calculatePointsSavings(expSavings, calSavings, income);

//Set user Level (Begineer, Intermediate , Expert)
        if (budgetRule == "50/30/20" && currentPts == 2000) {
          userLevel = "Expert";
        } else if ((budgetRule == "80/20" && currentPts == 1000) ||
            (budgetRule == "50/30/20" && currentPts <= 2000)) {
          userLevel = "Intermediate";
        } else {
          userLevel = "Beginner";
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          "ruleWinStreak": winStreak,
          "currentLevel": userLevel,
        });

//Update Income
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection('monthly_income')
            .doc(monthyear)
            .update({
          "needs": expNeeds,
          "wants": expWants,
          "savings": expSavings,
          "remainAmount": remainAmount,
          "totalCredit": totalCredit,
          "totalDebit": totalDebit,
          "currentLevel": userLevel,
          "updatedAt": timestamp,
        });
      }

      // Update points
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection('point_history')
          .doc(monthyear)
          .update({
        "NeedsPoints": needspts,
        "WantsPoints": wantspts,
        "SavingsPoints": savingsspts,
        "CurrentPoints": currentPts,
        "CombinePoints": combinePts,
        "PtsSavings": savePts,
      });

      // Save into transaction history
      var transactionData = {
        "id": id,
        "title": titleEditController.text,
        "amount": amount,
        "type": type,
        "timestamp": timestamp,
        "remainAmount": remainAmount,
        "totalCredit": totalCredit,
        "totalDebit": totalDebit,
        "monthyear": monthyear,
        "category": category,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("transactions")
          .doc(id)
          .set(transactionData);

      var ExpensesData = {
        "Total Income": income,
        "Level": userLevel,
        "budgetRule": budgetRule,
        "saving pts": savePts,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("expenses_record")
          .doc(monthyear)
          .update(ExpensesData);

      setState(() {
        isLoader = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.teal.shade800,
                ),
                child: const Text(
                  "Add New Transaction",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Enter transaction title",
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.amountValidator,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "(RM) Amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Enter transaction amount",
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              CategoryDropDown(
                cattype: category,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: budget,
                items: const [
                  DropdownMenuItem(
                    value: "needs",
                    child: Text("Needs"),
                  ),
                  DropdownMenuItem(
                    value: "wants",
                    child: Text("Wants"),
                  ),
                  DropdownMenuItem(
                    value: "savings",
                    child: Text("Savings"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(
                      () {
                        budget = value as String;
                      },
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: "Budget Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: type,
                items: const [
                  DropdownMenuItem(
                    value: "debit",
                    child: Text("Debit"),
                  ),
                  DropdownMenuItem(
                    value: "credit",
                    child: Text("Credit"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(
                      () {
                        type = value as String;
                      },
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (!isLoader) {
                      submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.teal.shade100,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isLoader
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Add Transaction"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
