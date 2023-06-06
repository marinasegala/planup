import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/notes.dart';
import '../db/notes_rep.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNote extends StatefulWidget {
  final String travel;
  const CreateNote({Key? key, required this.travel}) : super(key: key);

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final _formKey = GlobalKey<FormState>();

  final NoteRepository repository = NoteRepository();
  String name = '';
  String desc = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.notes),
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
                      decoration: InputDecoration(
                          icon: const Icon(Icons.edit_document),
                          hintText: AppLocalizations.of(context)!.nameNote),
                      onChanged: (text) => name = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.requiredField;
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
                      decoration: InputDecoration(
                          icon: const Icon(Icons.description_outlined),
                          hintText:
                              AppLocalizations.of(context)!.descriptionNote),
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
                                trav: widget.travel,
                                desc: desc,
                                userid: FirebaseAuth.instance.currentUser?.uid
                              );
                              repository.add(
                                  newShop); //.then((DocumentReference doc) => this.listId.add(doc));
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
