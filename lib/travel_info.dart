import 'package:flutter/material.dart';
import 'package:planup/show/item_card.dart';

import 'db/travel_rep.dart';
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
        ),
        
        //body: const Center(child: Text('TODO: add widget')),

        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              ItemWidget(name: 'Biglietti'),
              const SizedBox(height: 10),
              ItemWidget(name: 'Mappa'),
              const SizedBox(height: 10),
              ItemWidget(name: 'Acquisti in comune'),
              const SizedBox(height: 10),
              ItemWidget(name: 'Cosa portare'),
              const SizedBox(height: 10),
              ItemWidget(name: 'Note'),
          ]),
        ),
      ),
    );
  }
}