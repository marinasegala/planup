import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/notes.dart';
import 'package:planup/model/travel.dart';
import '../db/notes_rep.dart';
import '../db/users_rep.dart';
import '../model/user_account.dart';
import '../show/note_card.dart';
import 'create_note.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Notes extends StatefulWidget {
  final Travel trav;
  const Notes({Key? key, required this.trav}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late TextEditingController controller;

  late List<UserAccount> users = [];
  final UsersRepository usersRepository = UsersRepository();

  void getUsers() {
    // obtain users from the repository and add to the list
    usersRepository.getUsers().then((usersList) {
      setState(() {
        users = usersList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    getUsers();
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
          title: Text(AppLocalizations.of(context)!.notes),
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
                return Center(
                    child: Text(AppLocalizations.of(context)!.loading));
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
    return Center(
        child: Text(
      AppLocalizations.of(context)!.noNotes,
      style: const TextStyle(fontSize: 17),
    ));
  }

  Widget _buildList(
      BuildContext context, List<DocumentSnapshot>? snapshot, String id) {
    return ListView(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
      children:
          snapshot!.map((data) => _buildListItem(context, data, id)).toList(),
    );
  }

  Widget _buildListItem(
      BuildContext context, DocumentSnapshot snapshot, String id) {
    final note = Note.fromSnapshot(snapshot);
    String author = '';
    if (FirebaseAuth.instance.currentUser != null) {
      if (note.trav == id) {
        for (var x in users) {
          if (x.userid == note.userid) {
            author = x.name;
            break;
          }
        }
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
