import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/create_travel.dart';
import 'package:planup/model/shopping.dart';

import '../db/shopping_rep.dart';
import '../show/shop_card.dart';
import 'create_shop.dart';

class Shopping extends StatefulWidget{
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  final DataRepository repository = DataRepository();
  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I miei acquisti'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        
        // body: const Center(child: Text('TODO: add widget')),
        body: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _noItem();
            } //const LinearProgressIndicator();
            return _buildList(context, snapshot.data?.docs ?? []);
          }),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateShopItem()),
            );
          },
          backgroundColor: const Color.fromARGB(255, 255, 217, 104),
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
        
      ),
    );
  }

  Widget _noItem() {
    //TODO: sistemare perche non va
    return const Center(child: Text('Non hai viaggi'));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final shop = Shop.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (shop.userid == FirebaseAuth.instance.currentUser?.uid) {
        return ShopCard(shop: shop, boldStyle: boldStyle);
      }
    }
    return const SizedBox.shrink();
  }

}