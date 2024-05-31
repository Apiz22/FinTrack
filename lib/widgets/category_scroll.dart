import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/icons.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onChanged});
  final ValueChanged<String?> onChanged;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String currentCategory = "";
  List<Map<String, dynamic>> categoryList = [];

  final scrollController = ScrollController();
  var appIcons = AppIcons();

  @override
  void initState() {
    super.initState();
    setState(() {
      categoryList = appIcons.homeExpensesCategories;
      categoryList.insert(0, addCat);
    });
  }

  var addCat = {
    "name": "All",
    "icon": FontAwesomeIcons.cartPlus,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        controller: scrollController,
        itemCount: categoryList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var data = categoryList[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                currentCategory = data['name'];
                widget.onChanged(data['name']);
              });
            },
            child: Container(
              // width: 90,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  color: currentCategory == data['name']
                      ? Colors.black
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Row(
                children: [
                  Icon(
                    data['icon'],
                    size: 15,
                    color: currentCategory == data['name']
                        ? const Color.fromRGBO(253, 253, 253, 1)
                        : const Color.fromARGB(255, 19, 1, 0),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    data['name'],
                    style: TextStyle(
                      color: currentCategory == data['name']
                          ? const Color.fromRGBO(253, 253, 253, 1)
                          : const Color.fromARGB(255, 19, 1, 0),
                    ),
                  ),
                ],
              )),
            ),
          );
        },
      ),
    );
  }
}
