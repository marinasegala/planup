import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/shopping.dart';

import '../db/shopping_rep.dart';

class CreateShopItem extends StatefulWidget {
  CreateShopItem({Key? key}) : super(key: key);

  @override
  State<CreateShopItem> createState() => _CreateItemState();
}


class _CreateItemState extends State<CreateShopItem>{
  final _formKey = GlobalKey<FormState>();

  String? nameShop;
  String price = '';
  String desc='';
  final DataRepository repository = DataRepository();
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Nuovo acquisto'),
      ),
      body: Column(children: [
        const SizedBox(height: 30,),
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        if (_formKey.currentState!.validate()) {
                          if(desc==''){
                            desc='null';
                          }
                          final newShop = Shop(nameShop!,
                              price: double.parse(price),
                              desc: desc,
                              userid: FirebaseAuth.instance.currentUser?.uid);
                          repository.add(newShop);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Data')));
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Invia', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],)
    );
  }
}