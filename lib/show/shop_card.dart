
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
    Icon iconTheme = const Icon(Icons.info_outline);
    switch(shop.theme){
      case 'Alloggio':
        iconTheme = const Icon(Icons.home_outlined);
        break;
      case 'Alimentari':
        iconTheme = const Icon(Icons.fastfood_outlined);
        break;
      case 'Ristorante':
        iconTheme = const Icon(Icons.restaurant_menu_outlined);  
        break;
      case 'Svago':
        iconTheme = const Icon(Icons.local_activity_outlined);
        break;
      case 'Regali':
        iconTheme = const Icon(Icons.shopping_bag_outlined);
        break;
      case 'Trasporti':
        iconTheme = const Icon(Icons.train_outlined);
        break;
      case 'Benzina':
        iconTheme = const Icon(Icons.directions_car_outlined);
        break;
      default: 
    }
    
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:<Widget> [
          ListTile(
            leading: iconTheme,
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
