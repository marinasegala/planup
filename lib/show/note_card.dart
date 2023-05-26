import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          ListTile(
            title: Text(
              note.name,
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: description
                ? Text('Autore: $author')
                : Text('Autore: $author \n ${note.desc}'),
            trailing: IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('note')
                    .where('name', isEqualTo: note.name)
                    .get()
                    .then((querySnapshot) {
                  for (var docSnapshot in querySnapshot.docs) {
                    print('${docSnapshot.id} - ${docSnapshot.data()}');
                    deleteItem(docSnapshot.id);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
