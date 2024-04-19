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
  var titleEditCntroller = TextEditingController();
  var uid = Uuid();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      var amount = int.parse(amountEditController.text);
      DateTime date = DateTime.now();

      var id = uid.v4();
      String monthyear = DateFormat("MMM y").format(date);

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      int remainAmount = userDoc["remainAmount"];
      int totalCredit = userDoc["totalCredit"];
      int totalDebit = userDoc["totalDebit"];

      if (type == "credit") {
        remainAmount += amount;
        totalCredit += amount;
      } else {
        remainAmount -= amount;
        totalDebit += amount;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "remainAmount": remainAmount,
        "totalCredit": totalCredit,
        "totalDebit": totalDebit,
        "updatedAt": timestamp,
      });

      var data = {
        "id": id,
        "title": titleEditCntroller.text,
        "amount": amount,
        "type": type,
        "timestamp": timestamp,
        "remainAmount": remainAmount,
        "totalCredit": totalCredit,
        "totalDebit": totalDebit,
        "monthyear": monthyear,
        "category": category,
        // "budget": budget,
      };

      // Save transaction data to the "history" subcollection of the user document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid) //!uid
          .collection("transactions")
          .doc(id) // Use transaction ID as document ID
          .set(data);

      // Navigator.pop(context);

      setState(() {
        isLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add page"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleEditCntroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: InputDecoration(
                  labelText: "title",
                ),
              ),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
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
              SizedBox(
                height: 10,
              ),
              //budget type (needs, wants , saving)
              DropdownButtonFormField(
                value: 'savings',
                items: [
                  DropdownMenuItem(
                    child: Text("needs"),
                    value: "needs",
                  ),
                  DropdownMenuItem(
                    child: Text("wants"),
                    value: "wants",
                  ),
                  DropdownMenuItem(
                    child: Text("saving"),
                    value: "savings",
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
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                value: 'credit',
                items: [
                  DropdownMenuItem(
                    child: Text("debit"),
                    value: "debit",
                  ),
                  DropdownMenuItem(
                    child: Text("credit"),
                    value: "credit",
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
              SizedBox(
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
