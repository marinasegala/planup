import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/shopping.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/widgets/create_shop.dart';
import '../db/shopping_rep.dart';
import '../show/shop_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Shopping extends StatefulWidget {
  final Travel trav;
  const Shopping({Key? key, required this.trav}) : super(key: key);

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  List<DocumentReference> listId = [];

  final ShopRepository repository = ShopRepository();
  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myShopping),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: repository.getStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text(AppLocalizations.of(context)!.loading));
              } else {
                final hasMyOnwData =
                    _hasMyOnwData(snapshot, widget.trav.referenceId!);
                if (!hasMyOnwData) {
                  return _noItem();
                } else {
                  return _buildList(
                      context, snapshot.data!.docs, widget.trav.referenceId!);
                }
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) =>
                        CreateShopItem(travel: widget.trav.referenceId!)));
          },
          backgroundColor: const Color.fromARGB(255, 255, 217, 104),
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

 Widget _noItem() {
    return Center(
        child: Text(
      AppLocalizations.of(context)!.noShopping,
      style: const TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    ));
  }
  Widget _buildList(
      BuildContext context, List<DocumentSnapshot>? snapshot, String id) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children:
          snapshot!.map((data) => _buildListItem(context, data, id)).toList(),
    );
  }

  Widget _buildListItem(
      BuildContext context, DocumentSnapshot snapshot, String id) {
    final shop = Shop.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (shop.userid == FirebaseAuth.instance.currentUser?.uid &&
          shop.trav == id) {
        return ShopCard(shop: shop, boldStyle: boldStyle);
      }
    }
    return const SizedBox.shrink();
  }
}

bool _hasMyOnwData(AsyncSnapshot<QuerySnapshot> snapshot, String id) {
  bool datas = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final shop = snapshot.data!.docs;
  for (var i = 0; i < shop.length; i++) {
    if (shop[i]['userid'] == currentUser.uid && shop[i]['trav'] == id) {
      datas = true;
      return datas;
    }
  }
  return datas;
}
