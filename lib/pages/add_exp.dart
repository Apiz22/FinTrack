import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_v2/utils/appvalidator.dart';
import 'package:ft_v2/widgets/category_dropdown.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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

  Future<void> _submitForm() async {
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

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection('monthly_income')
          .doc(monthyear)
          .get();

      double remainAmount = userDoc["remainAmount"].toDouble();
      double totalCredit = userDoc["totalCredit"].toDouble();
      double totalDebit = userDoc["totalDebit"].toDouble();
      double expNeeds = userDoc["needs"].toDouble();
      double expWants = userDoc["wants"].toDouble();
      double expSavings = userDoc["savings"].toDouble();

      if (type == "credit") {
        remainAmount += amount;
        totalCredit += amount;
      } else {
        remainAmount -= amount;
        totalDebit += amount;
      }

      if (budget == "needs") {
        expNeeds += amount;
      } else if (budget == "wants") {
        expWants += amount;
      } else {
        expSavings += amount;
      }

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
                decoration: InputDecoration(
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
                decoration: InputDecoration(
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
                        budget = value;
                      },
                    );
                  }
                },
                decoration: InputDecoration(
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
                        type = value;
                      },
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (!isLoader) {
                      _submitForm();
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