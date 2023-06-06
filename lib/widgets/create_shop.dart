import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/shopping.dart';
import '../db/shopping_rep.dart';
import 'customdropdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateShopItem extends StatefulWidget {
  final String travel;
  const CreateShopItem({Key? key, required this.travel}) : super(key: key);

  @override
  State<CreateShopItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateShopItem> {
  final _formKey = GlobalKey<FormState>();
  String? selectedValue;

  String? nameShop;
  String price = '';
  String desc = '';

  final ShopRepository repository = ShopRepository();

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      AppLocalizations.of(context)!.accomodation,
      AppLocalizations.of(context)!.food,
      AppLocalizations.of(context)!.restaurant,
      AppLocalizations.of(context)!.freeTime,
      AppLocalizations.of(context)!.presents,
      AppLocalizations.of(context)!.transport,
      AppLocalizations.of(context)!.gasoline,
      AppLocalizations.of(context)!.other,
    ];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.newShopping),
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    child: TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          hintText:
                              AppLocalizations.of(context)!.addNameShopping),
                      onChanged: (text) => nameShop = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.requiredField;
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    child: TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.euro_outlined),
                          hintText: AppLocalizations.of(context)!.price),
                      onChanged: (text) => price = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.requiredField;
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.04,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    child: TextField(
                      maxLength: MediaQuery.of(context).size.height.toInt(),
                      autofocus: true,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.description_outlined),
                          hintText: AppLocalizations.of(context)!
                              .descriptionShopping),
                      onChanged: (text) => desc = text,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.03,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05),
                        SizedBox(
                          child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .categoryShopping,
                                  style: const TextStyle(fontSize: 15),
                                  textAlign: TextAlign.center)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        CustomDropdownButton(
                          hint:
                              AppLocalizations.of(context)!.addCategoryShopping,
                          dropdownItems: items,
                          value: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser != null) {
                            if (_formKey.currentState!.validate()) {
                              if (desc == '') {
                                desc = 'null';
                              }
                              final newShop = Shop(nameShop!,
                                  price: double.parse(price),
                                  desc: desc,
                                  theme: selectedValue,
                                  userid:
                                      FirebaseAuth.instance.currentUser?.uid,
                                  trav: widget.travel);
                              repository.add(newShop);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .processingData)));
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.send,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
