
import 'package:flutter/material.dart';

import 'package:planup/travel_info.dart';

import '../model/shopping.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final TextStyle boldStyle;
  const ShopCard({Key? key, required this.shop, required this.boldStyle})
      : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.album),
            title: Text(shop.name),
            subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('BUY TICKETS'),
                onPressed: () {/* ... */},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('LISTEN'),
                onPressed: () {/* ... */},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ), 
    );
    // return Card(
    //   elevation: 2,
    //   child: InkWell(
    //     child: Row(
    //       children: <Widget>[
    //         Expanded(
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0),
    //             child: Text(shop.name, style: boldStyle),
    //           ),
    //         ),
    //       ],
    //     ),
    //     onTap: (){}
    //   )
    // );
  }
}
