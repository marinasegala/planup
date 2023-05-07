import 'package:flutter/material.dart';
import 'package:planup/show/item_card.dart';
import 'package:planup/widgets/tickets.dart';

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
              const SizedBox(height: 30),
              ItemWidget(name: 'Biglietti', icon: Icons.airplane_ticket, index: 1,),
              const SizedBox(height: 10),
              ItemWidget(name: 'Mappa', icon: Icons.map, index: 2,),
              const SizedBox(height: 10),
              ItemWidget(name: 'Acquisti in comune', icon: Icons.euro_symbol, index: 3,),
              const SizedBox(height: 10),
              ItemWidget(name: 'Cosa portare', icon: Icons.shopping_bag, index: 4,),
              const SizedBox(height: 10),
              ItemWidget(name: 'Note', icon: Icons.note, index: 5,),
          ]),
        ),
      ),
    );
  }
}