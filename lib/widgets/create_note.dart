import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/notes.dart';

import '../db/notes_rep.dart';

class CreateNote extends StatefulWidget {
  final String trav;
  const CreateNote({Key? key, required this.trav}) : super(key: key);

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final _formKey = GlobalKey<FormState>();

  final DataRepository repository = DataRepository();
  String name = '';
  String desc = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Nuova Nota'),
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
                          hintText: 'Nome nota *'),
                      onChanged: (text) => name = text,
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
                              if (desc == '') {
                                desc = 'null';
                              }
                              final newShop = Note(
                                name,
                                trav: widget.trav,
                                desc: desc,
                                userid: FirebaseAuth.instance.currentUser?.uid,
                              );
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
