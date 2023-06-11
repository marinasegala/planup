import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/notes.dart';

// ignore: must_be_immutable
class NoteCard extends StatelessWidget {
  final Note note;
  final TextStyle boldStyle;
  String author;
  NoteCard(
      {Key? key,
      required this.note,
      required this.boldStyle,
      required this.author})
      : super(key: key);

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Future<void> deleteItem(String id) {
      return FirebaseFirestore.instance
          .collection("note")
          .doc(id)
          .delete()
          .then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );
    }

    bool description = false;
    if (note.desc == 'null') {
      description = true;
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ListTile(
            title: Text(
              note.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: description
                ? Text(AppLocalizations.of(context)!.authorNote(author))
                
                : Text(AppLocalizations.of(context)!
                    .authorNoteWithDescription(author, note.desc), textAlign: TextAlign.left),
            
            trailing: note.userid == currentUser?.uid
                ? IconButton(
                    icon: const Icon(Icons.close_outlined),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('note')
                          .doc(note.referenceId)
                          .get()
                          .then((querySnapshot) {
                        deleteItem(querySnapshot.id);
                      });
                    },
                  )
                : SizedBox.shrink(),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      ),
    );
  }
}
