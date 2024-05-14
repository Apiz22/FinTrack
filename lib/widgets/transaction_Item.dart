import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ft_v2/utils/icons.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  TransactionItem({
    super.key,
    this.data,
  });

  final dynamic data;

  var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(data['timestamp']);
    String formatDate = DateFormat('d MMM hh:mm').format(date);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 10),
              blurRadius: 10,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            minVerticalPadding: 8,
            contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            leading: Container(
              width: 70,
              height: 100,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: data['type'] == 'credit'
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
                child: Center(
                    child: FaIcon(appIcons
                        .getExpenseCategoryIcons('${data['category']}'))),
              ),
            ),
            title: Row(
              children: [
                Expanded(child: Text("${data['title']}")),
                Text(
                  " ${data['type'] == 'credit' ? '+' : '-'} RM ${data['amount']}",
                  style: TextStyle(
                    color: data['type'] == 'credit' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("balance"),
                    Spacer(),
                    Text(
                      "RM ${data['remainAmount']}",
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatDate,
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
