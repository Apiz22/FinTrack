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
  var category = "Others";
  var budget = "needs";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var isLoader = false;
  var appValidator = AppValidator();
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  var uid = const Uuid();

  final Points points = Points();

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      int timestamp = DateTime.now().microsecondsSinceEpoch;
      var amount = double.parse(amountEditController.text);
      DateTime date = DateTime.now();
      var id = uid.v4();
      String monthyear = DateFormat("MMM y").format(date);

//retrieve user current income
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

      final pointsDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection('point_history')
          .doc(monthyear)
          .get();

      int needspts = pointsDoc["NeedsPoints"];
      int wantspts = pointsDoc["WantsPoints"];
      int savingsspts = pointsDoc["SavingsPoints"];
      String budgetRule = pointsDoc["budgetRule"].toString();
      double com = 0;

//cal expenses amount
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
          com = expNeeds + expWants;
          needspts += points.calculatePoints(
              budgetRule, amount, expNeeds, calNeeds, income, budget, com);
        } else if (budget == "wants") {
          expWants += amount;
          com = expNeeds + expWants;

          wantspts += points.calculatePoints(
              budgetRule, amount, expWants, calWants, income, budget, com);
        } else {
          expSavings += amount;
          savingsspts += points.calculatePoints(
              budgetRule, amount, expSavings, calSavings, income, budget, com);
        }

        currentPts = needspts + wantspts + savingsspts;

        if (budgetRule == "50/30/20") {
          int pointsLimit = 2000;
          currentPts = (currentPts > pointsLimit) ? pointsLimit : currentPts;
        } else {
          int pointsLimit = 1000;
          currentPts = (currentPts > pointsLimit) ? pointsLimit : currentPts;
        }

// // Format values to 2 decimal places
//       remainAmount = double.parse(remainAmount.toStringAsFixed(2));
//       totalCredit = double.parse(totalCredit.toStringAsFixed(2));
//       totalDebit = double.parse(totalDebit.toStringAsFixed(2));
//       expNeeds = double.parse(expNeeds.toStringAsFixed(2));
//       expWants = double.parse(expWants.toStringAsFixed(2));
//       expSavings = double.parse(expSavings.toStringAsFixed(2));

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
          "updatedAt": timestamp,
        });
      }

      //  update points
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
      });

//save into transaction history
      var data = {
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
          .set(data);

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
        title: const Text("Add Expense"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Transaction",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  hintText: "Enter transaction title",
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                  hintText: "Enter transaction amount",
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
                decoration: const InputDecoration(
                  labelText: "Budget Type",
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (!isLoader) {
                      submitForm();
                      // calculatePoint();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
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
