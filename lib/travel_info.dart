import 'package:flutter/material.dart';
import 'package:planup/settings_travel.dart';
import 'package:planup/show/item_card.dart';
import 'model/travel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TravInfo extends StatelessWidget {
  final Travel trav;
  final bool isPast;
  const TravInfo({Key? key, required this.trav, required this.isPast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(trav.name),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingTravel(travel: trav, isPast: isPast)),
                  );
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: Center(
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ItemWidget(
              name: AppLocalizations.of(context)!.tickets,
              icon: Icons.airplane_ticket,
              index: 1,
              trav: trav,
              isPast: isPast,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ItemWidget(
              name: AppLocalizations.of(context)!.map,
              icon: Icons.map,
              index: 2,
              trav: trav,
              isPast: isPast,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ItemWidget(
              name: AppLocalizations.of(context)!.shopping,
              icon: Icons.euro_symbol,
              index: 3,
              trav: trav,
              isPast: isPast,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ItemWidget(
              name: AppLocalizations.of(context)!.whatBring,
              icon: Icons.checklist,
              index: 4,
              trav: trav,
              isPast: isPast,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ItemWidget(
              name: AppLocalizations.of(context)!.notes,
              icon: Icons.note,
              index: 5,
              trav: trav,
              isPast: isPast,
            ),
          ]),
        ),
      ),
    );
  }
}
