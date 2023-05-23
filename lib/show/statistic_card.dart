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
      width: MediaQuery.of(context).size.width / 3.3,
      height: MediaQuery.of(context).size.width / 3.3,
      child: Card(
        color: Colors.blueGrey[100],
        child: Column(
          children: [
            const SizedBox(height: 15),
            chooseIcon(widget.statisticTitle),
            const SizedBox(height: 10),
            Text(
              '${widget.statisticValue} \n${widget.statisticTitle}',
              style: const TextStyle(fontSize: 15, letterSpacing: 2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget chooseIcon(String icon) {
  switch (icon) {
    case 'Amici':
      return const Icon(Icons.people);
    case 'Viaggi':
      return const Icon(Icons.airplanemode_active);
    case 'Posti':
      return const Icon(Icons.place);
    default:
      return const Icon(Icons.error);
  }
}
