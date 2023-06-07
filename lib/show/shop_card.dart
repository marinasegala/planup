import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/shopping.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final TextStyle boldStyle;
  const ShopCard({Key? key, required this.shop, required this.boldStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> deleteItem(String id) {
      return FirebaseFirestore.instance
          .collection("shopping")
          .doc(id)
          .delete()
          .then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );
    }

    bool description = false;
    if (shop.desc == 'null') {
      description = true;
    }
    
    Icon iconTheme = const Icon(Icons.info_outline);
    if (shop.theme=='Alloggio' || shop.theme=='Accomodation'){
      iconTheme = const Icon(Icons.home_outlined);
    }
    else if (shop.theme=='Alimentari' || shop.theme=='Food'){
      iconTheme = const Icon(Icons.fastfood_outlined);
    }
    else if (shop.theme=='Ristorante' || shop.theme=='Restaurant'){
      iconTheme = const Icon(Icons.restaurant_menu_outlined);
    }
    else if (shop.theme=='Svago' || shop.theme=='Free time'){
      iconTheme = const Icon(Icons.local_activity_outlined);
    }
    else if (shop.theme=='Regali' || shop.theme=='Presents'){
      iconTheme = const Icon(Icons.shopping_bag_outlined);
    }
    else if (shop.theme=='Trasporti' || shop.theme=='Transport'){
      iconTheme = const Icon(Icons.train_outlined);
    }
    else if (shop.theme=='Benzina' || shop.theme=='Gasoline'){
      iconTheme = const Icon(Icons.directions_car_outlined);
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: iconTheme,
            title: Text(
              shop.name,
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: description ? const Text('') : Text(shop.desc),
            trailing: IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('shopping')
                    .where("name", isEqualTo: shop.name)
                    .get()
                    .then(
                  (querySnapshot) {
                    for (var docSnapshot in querySnapshot.docs) {
                      deleteItem(docSnapshot.id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
