import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planup/model/notes.dart';
import 'package:planup/model/travel.dart';

import '../db/notes_rep.dart';
import '../show/note_card.dart';
import 'create_note.dart';

class Notes extends StatefulWidget {
  final Travel trav;
  const Notes({Key? key, required this.trav}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();

  final NoteRepository repository = NoteRepository();
  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  String name = '';
  String desc = '';
  String author = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.pop();
              }),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: repository.getStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Loading..."));
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
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateNote(travel: widget.trav.referenceId!)),
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
    return const Center(
        child: Text(
      'Non hai ancora note',
      style: TextStyle(fontSize: 17),
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
    final note = Note.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (note.userid == FirebaseAuth.instance.currentUser?.uid &&
          note.trav == id) {
        FirebaseFirestore.instance
            .collection('users')
            .where('userid', isEqualTo: note.userid)
            .get()
            .then(
          (querySnapshot) {
            print("Successfully completed");
            for (var docSnapshot in querySnapshot.docs) {
              author = docSnapshot.get('name');
            }
          },
          onError: (e) => print("Error completing: $e"),
        );
        return NoteCard(note: note, boldStyle: boldStyle, author: author);
      }
    }
    return const SizedBox.shrink();
  }
}

bool _hasMyOnwData(AsyncSnapshot<QuerySnapshot> snapshot, String id) {
  bool datas = false;
  // final currentUser = FirebaseAuth.instance.currentUser!;
  final note = snapshot.data!.docs;
  for (var i = 0; i < note.length; i++) {
    if (note[i]['trav'] == id) {
      datas = true;
      return datas;
    }
  }
  return datas;
}
