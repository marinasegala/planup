import 'package:flutter/material.dart';

import 'db/travel_rep.dart';
import 'model/travel.dart';

class TravInfo extends StatelessWidget {

  final Travel trav;
  const TravInfo({Key? key, required this.trav}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(trav.name),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        
        body: const Center(child: Text('TODO: add widget')),
      ),
    );
  }
}