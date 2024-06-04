import 'package:flutter/material.dart';
import '../utils/icons.dart';

class CategoryDropDown extends StatefulWidget {
  CategoryDropDown({super.key, this.cattype, required this.onChanged});

  final String? cattype;
  final ValueChanged<String?> onChanged;

  @override
  State<CategoryDropDown> createState() => _CategoryDropDownState();
}

class _CategoryDropDownState extends State<CategoryDropDown> {
  var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: widget.cattype!.isEmpty ? null : widget.cattype,
          isExpanded: true,
          hint: const Text("Select Category"),
          items: appIcons.homeExpensesCategories
              .map((e) => DropdownMenuItem<String>(
                    value: e["name"],
                    child: Row(
                      children: [
                        Icon(
                          e["icon"],
                          color: Colors.black45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          e["name"],
                          style: const TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
