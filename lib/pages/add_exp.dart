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
  var type = "credit";
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
      var amount = int.parse(amountEditController.text);
      DateTime date = DateTime.now();
      var id = uid.v4();
      String monthyear = DateFormat("MMM y").format(date);

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection('monthly_income')
          .doc(monthyear)
          .get();

      int remainAmount = userDoc["remainAmount"];
      int totalCredit = userDoc["totalCredit"];
      int totalDebit = userDoc["totalDebit"];
      int expNeeds = userDoc["needs"];
      int expWants = userDoc["wants"];
      int expSavings = userDoc["savings"];

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add page"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //add title
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: const InputDecoration(
                  labelText: "title",
                ),
              ),
              //add value
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "value",
                ),
              ),
              //category dropp dowm
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
              const SizedBox(
                height: 10,
              ),
              //budget type (needs, wants , saving)
              DropdownButtonFormField(
                value: budget,
                items: const [
                  DropdownMenuItem(
                    value: "needs",
                    child: Text("needs"),
                  ),
                  DropdownMenuItem(
                    value: "wants",
                    child: Text("wants"),
                  ),
                  DropdownMenuItem(
                    value: "savings",
                    child: Text("saving"),
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
              ),
              //type credit or debit
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                value: 'credit',
                items: const [
                  DropdownMenuItem(
                    value: "debit",
                    child: Text("debit"),
                  ),
                  DropdownMenuItem(
                    value: "credit",
                    child: Text("credit"),
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
              ),
              const SizedBox(
                height: 16,
              ),
              //add transaction button
              ElevatedButton(
                  onPressed: () {
                    if (isLoader == false) {
                      _submitForm();
                    }
                  },
                  child: isLoader
                      ? const Center(child: CircularProgressIndicator())
                      : const Text("Add transaction"))
            ],
          ),
        ),
      ),
    );
  }
}
