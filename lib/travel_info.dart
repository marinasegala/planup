import 'package:flutter/material.dart';
import 'package:planup/settings_travel.dart';
import 'package:planup/show/item_card.dart';

import 'model/travel.dart';

class TravInfo extends StatelessWidget {
  final Travel trav;
  const TravInfo({Key? key, required this.trav}) : super(key: key);

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
                        builder: (context) => SettingTravel(travel: trav)),
                  );
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: Center(
          child: Column(children: [
            const SizedBox(height: 30),
            ItemWidget(
              name: 'Biglietti',
              icon: Icons.airplane_ticket,
              index: 1,
              trav: trav.name,
            ),
            const SizedBox(height: 10),
            ItemWidget(
              name: 'Mappa',
              icon: Icons.map,
              index: 2,
              trav: trav.name,
            ),
            const SizedBox(height: 10),
            ItemWidget(
              name: 'Acquisti personali',
              icon: Icons.euro_symbol,
              index: 3,
              trav: trav.name,
            ),
            const SizedBox(height: 10),
            ItemWidget(
              name: 'Cosa portare',
              icon: Icons.shopping_cart,
              index: 4,
              trav: trav.name,
            ),
            const SizedBox(height: 10),
            ItemWidget(
              name: 'Note',
              icon: Icons.note,
              index: 5,
              trav: trav.name,
            ),
          ]),
        ),
      ),
    );
  }
}
