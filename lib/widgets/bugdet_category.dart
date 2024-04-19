// import 'package:flutter/material.dart';

// class BudgetCategory extends StatefulWidget {
//   const BudgetCategory({super.key});

//   @override
//   State<BudgetCategory> createState() => _BudgetCategoryState();
// }

// class _BudgetCategoryState extends State<BudgetCategory> {

//  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
//  var dropdownValue = list.first;

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<String>(
//       value: dropdownValue,
//       icon: const Icon(Icons.arrow_downward),
//       elevation: 16,
//       style: const TextStyle(color: Colors.deepPurple),
//       underline: Container(
//         height: 2,
//         color: Colors.deepPurpleAccent,
//       ),
//       onChanged: (String? value) {
//         // This is called when the user selects an item.
//         setState(() {
//           dropdownValue = value!;
//         });
//       },
//       items: list.map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
      
//     );
//   }
// }