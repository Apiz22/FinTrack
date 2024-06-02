import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../utils/icons.dart';

class TransactionItem extends StatefulWidget {
  TransactionItem({
    Key? key,
    this.data,
  }) : super(key: key);

  final dynamic data;

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(widget.data['timestamp']);
    String formatDate = DateFormat('d MMM hh:mm').format(date);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 251, 251),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 10,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            minVerticalPadding: 8,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            leading: SizedBox(
              width: 70,
              height: 70,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: widget.data['type'] == 'credit'
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
                child: Center(
                  child: FaIcon(
                    appIcons
                        .getExpenseCategoryIcons('${widget.data['category']}'),
                    color: Colors.black87,
                    // color: data['type'] == 'credit' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "${widget.data['title']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 48, 48, 48),
                    ),
                  ),
                ),
                Text(
                  " ${widget.data['type'] == 'credit' ? '+' : '-'} RM ${widget.data['amount'].toStringAsFixed(2)}",
                  style: TextStyle(
                    color: widget.data['type'] == 'credit'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
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
                    const Text(
                      "Balance",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 77, 77, 77),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "RM ${widget.data['remainAmount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatDate,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 105, 105, 105),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
