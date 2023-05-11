
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
      elevation: 2,
      child: InkWell(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 16.0),
                child: Text(shop.name, style: boldStyle),
              ),
            ),
          ],
        ),
        onTap: (){}
      )
    );
  }
}
