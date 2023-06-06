import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticCard extends StatefulWidget {
  const StatisticCard(
      {super.key, required this.statisticTitle, required this.statisticValue});

  final String statisticTitle;
  final int statisticValue;

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard> {
  String getTitle() {
    switch (widget.statisticTitle) {
      case 'Amici':
        return AppLocalizations.of(context)!.friends;
      case 'Viaggi':
        return AppLocalizations.of(context)!.travels;
      case 'Posti':
        return AppLocalizations.of(context)!.places;
      default:
        return AppLocalizations.of(context)!.friends;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.3,
      height: MediaQuery.of(context).size.width / 3.3,
      child: Card(
        color: Colors.blueGrey[100],
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            chooseIcon(widget.statisticTitle),
            SizedBox(height: MediaQuery.of(context).size.width * 0.03),
            Text(
              AppLocalizations.of(context)!.statisticCardTitle(
                  widget.statisticValue.toString(), getTitle()),
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
