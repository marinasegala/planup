import 'package:flutter/material.dart';

class StatisticCard extends StatefulWidget {
  const StatisticCard(
      {super.key, required this.statisticTitle, required this.statisticValue});

  final String statisticTitle;
  final int statisticValue;

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(widget.statisticTitle,
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 20),
            Text(
              widget.statisticValue.toString(),
              style: const TextStyle(fontSize: 22),
            )
          ],
        ),
      ),
    );
  }
}
