
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
    bool description= false;
    if(shop.desc == 'null'){
      description = true;
    }
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:<Widget> [
          ListTile(
            leading: const Icon(Icons.album),
            title: Text(shop.name, style: const TextStyle(fontSize: 18),),
            subtitle: description ? const Text('') : Text(shop.desc)
          ),
          
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[
          //     TextButton(
          //       child: const Text('BUY TICKETS'),
          //       onPressed: () {/* ... */},
          //     ),
          //     const SizedBox(width: 8),
          //   ],
          // ),
        ],
      ), 
    );
  }
}
