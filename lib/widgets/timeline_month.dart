import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeLineMonth extends StatefulWidget {
  const TimeLineMonth({super.key, required this.onChanged});
  final ValueChanged<String?> onChanged;

  @override
  State<TimeLineMonth> createState() => _TimeLineMonthState();
}

class _TimeLineMonthState extends State<TimeLineMonth> {
  String currentMonth = "";
  List<String> months = [];

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    for (int i = -13; i <= 0; i++) {
      months.add(
          DateFormat("MMM y").format(DateTime(now.year, now.month + i, 1)));
    }
    currentMonth = DateFormat('MMM y').format(now);

    Future.delayed(const Duration(seconds: 1), () {
      scrollToSelectedMonth();
    });
  }

  scrollToSelectedMonth() {
    final selectedMonthIndex = months.indexOf(currentMonth);
    if (selectedMonthIndex != -1) {
      final scrollOffset = (selectedMonthIndex * 100.0) - 170;
      scrollController.animateTo(scrollOffset,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: scrollController,
        itemCount: months.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = months[index];
                widget.onChanged(months[index]);
              });
              scrollToSelectedMonth();
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: currentMonth == months[index]
                      ? Colors.teal.shade500
                      : Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Text(
                months[index],
                style: TextStyle(
                  color: currentMonth == months[index]
                      ? const Color.fromRGBO(253, 253, 253, 1)
                      : const Color.fromARGB(255, 19, 1, 0),
                ),
              )),
            ),
          );
        },
      ),
    );
  }
}
