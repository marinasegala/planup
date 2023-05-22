import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/shopping.dart';

import '../db/shopping_rep.dart';
import 'customdropdown.dart';

class CreateShopItem extends StatefulWidget {
  final String trav;
  const CreateShopItem({Key? key, required this.trav}) : super(key: key);

  @override
  State<CreateShopItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateShopItem> {
  final _formKey = GlobalKey<FormState>();
  final List<String> items = [
    'Alloggio',
    'Alimentari',
    'Ristorante',
    'Svago',
    'Regali',
    'Trasporti',
    'Benzina',
    'Altro',
  ];
  String? selectedValue;

  String? nameShop;
  String price = '';
  String desc = '';

  final ShopRepository repository = ShopRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Nuovo acquisto'),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.shopping_bag_outlined),
                          hintText: 'Inserire il nome della nuova spesa *'),
                      onChanged: (text) => nameShop = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obbligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.euro_outlined),
                          hintText: 'Prezzo *'),
                      onChanged: (text) => price = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obbligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      maxLength: 30,
                      autofocus: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.description_outlined),
                          hintText: 'Descrizione'),
                      onChanged: (text) => desc = text,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 34),
                        const SizedBox(
                          // width: 180.0,
                          // height: 40.0,
                          child: Center(
                              child: Text(
                                  'Categoria della spesa',
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.center)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        CustomDropdownButton(
                          hint: 'Seleziona la categoria della tua spesa',
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
                  const SizedBox(height: 30),
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
                                  trav: widget.trav);
                              repository.add(
                                  newShop); //.then((DocumentReference doc) => this.listId.add(doc));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')));
                              Navigator.pop(context);
                            }
                          }
                        },
                        child:
                            const Text('Invia', style: TextStyle(fontSize: 16)),
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

// List<DropdownMenuItem<String>> addDividersAfterItems(List<String> items) {
//   List<DropdownMenuItem<String>> menuItems = [];
//   for (var item in items) {
//     menuItems.addAll(
//       [
//         DropdownMenuItem<String>(
//           value: item,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(
//               item,
//               style: const TextStyle(
//                 fontSize: 17,
//               ),
//             ),
//           ),
//         ),
//         //If it's last item, we will not add Divider after it.
//         if (item != items.last)
//           const DropdownMenuItem<String>(
//             enabled: false,
//             child: Divider(),
//           ),
//       ],
//     );
//   }
//   return menuItems;
// }

// List<double> getCustomItemsHeights() {
//   List<double> itemsHeights = [];
//   for (var i = 0; i < (items.length * 2) - 1; i++) {
//     if (i.isEven) { itemsHeights.add(40); }
//     //Dividers indexes will be the odd indexes
//     if (i.isOdd) { itemsHeights.add(4); }
//   }
//   return itemsHeights;
// }