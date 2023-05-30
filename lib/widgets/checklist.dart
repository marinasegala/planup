import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import '../db/checklist_rep.dart';
import '../db/users_rep.dart';
import '../model/checklist.dart';
import '../model/travel.dart';
import '../model/user_account.dart';
import '../show/item_listcheck.dart';

// ignore: must_be_immutable
class ItemCheckList extends StatefulWidget {
  Travel trav;
  ItemCheckList({Key? key, required this.trav}) : super(key: key);

  @override
  State<ItemCheckList> createState() => _CheckListState();
}

enum StateList { privata, pubblica }

class _CheckListState extends State<ItemCheckList> {
  final ListRepository repository = ListRepository();
  final UsersRepository userRepository = UsersRepository();
  final TravelRepository travRepository = TravelRepository();

  late List<UserAccount> users;
  late List<String> otherPart = [];

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  StateList? _statelist = StateList.privata;

  late String list = currentUser?.uid as String;
  int count = 2;

  List<UserAccount> getUsers() {
    List<UserAccount> _users = [];
    userRepository.getStream().listen((event) {
      _users = event.docs
          .map((e) => UserAccount.fromSnapshot(e))
          .where((element) => element.userid != currentUser?.uid)
          .toList();
    });
    return _users;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  late String? profilePhoto;

  String nameItem= '';

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      for (final providerProfile in currentUser!.providerData) {
        profilePhoto = providerProfile.photoURL;
      }
    }
    users = getUsers();
  }

  Future<void> updateItem(String field, bool newField, String id) {
    return FirebaseFirestore.instance
        .collection('check')
        .doc(id)
        .update({field: newField}).then(
            (value) => print("Update")
            ,onError: (e) => print("Error updating doc: $e")
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Check List'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            height: 100.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                const SizedBox(
                  width: 10,
                ),
                createButton('La mia lista', profilePhoto as String, currentUser?.uid as String),
                createButton(widget.trav.name, '', 'group'),
                StreamBuilder<QuerySnapshot>(
                  stream: travRepository.getStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    } else {
                      otherPart = parts(snapshot, widget.trav.name);
                      if (otherPart.isNotEmpty) {
                        return StreamBuilder<QuerySnapshot>(
                            stream: userRepository.getStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Text("Loading..."));
                              } else {
                                return _buildListPartecipant(context,
                                    snapshot.data!.docs, otherPart, 2);
                              }
                            });
                      }
                      return const SizedBox.shrink();
                    }
                }),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Radio<StateList>(
                  value: StateList.pubblica,
                  groupValue: _statelist,
                  onChanged: (StateList? value) {
                    setState(() {
                      _statelist = value;
                    });
                  },
                ),
                const Text('Pubblica', style: TextStyle(fontSize: 17)),
                Radio<StateList>(
                  value: StateList.privata,
                  groupValue: _statelist,
                  onChanged: (StateList? value) {
                    setState(() {
                      _statelist = value;
                    });
                  },
                ),
                const Text('Privata', style: TextStyle(fontSize: 17)),
              ],
            ),
          ),
          const Text(
            'Se la lista è pubblica, i tuoi compagni di viaggio la possono vedere',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),

          list == currentUser?.uid
            ? StreamBuilder<QuerySnapshot>(
              stream: ListRepository().getStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading...'));
                } else {
                  final hasDataList = _hasDataList(snapshot, 'personal');
                  if (!hasDataList) {
                    return _noItem();
                  } else {
                    return _buildListCheck(context, snapshot.data!.docs, list);
                  }
                }
              },
            )
            : const SizedBox.shrink(),

          list == 'group'
            ? StreamBuilder<QuerySnapshot>(
              stream: ListRepository().getStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading...'));
                } else {
                  final hasDataList = _hasDataList(snapshot, 'group');
                  if (!hasDataList) {
                    return _noItem();
                  } else {
                    return _buildListCheck(context, snapshot.data!.docs, list);
                  }
                }
              },
            )
            : const SizedBox.shrink(),
      ]),
      floatingActionButton: list == 'group' || list == currentUser?.uid
      ? FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Nuovo oggetto'),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                          ),
                          onChanged: (text) => nameItem = text,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [ ElevatedButton(
                  child: const Text("Invia"),
                  onPressed: () {
                    final newitemList = Check(
                      nameItem,
                      trav: widget.trav.referenceId,
                      creator: currentUser?.uid,
                      isgroup: list == 'group' ? true : false,
                      isPublic: false,
                      isChecked: false,
                    );
                    repository.add(newitemList); 
                    Navigator.of(context).pop();
                  })
                ],
              );
            });
        }, 
        backgroundColor: const Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      )
      : const SizedBox.shrink(),
    );
  }

  Widget _noItem() {
    return const Center(
        child: Text(
      'Non sono ancora presenti gli oggetti da portare',
      style: TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    ));
  }

  Widget createButton(String name, String photo, String id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      onPressed: (){
        setState(() {
          list = id;
        });
      }, 
      child: Column(children: [
        name == widget.trav.name
        ? const CircleAvatar(
          radius: 27,
          child: Icon(Icons.group_outlined, size: 30,),
        )
        : CircleAvatar(
          backgroundImage: NetworkImage(photo),
          radius: 27,
        ),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: Colors.black),)
      ]),
    );
  }

  Widget _buildListPartecipant(BuildContext context, List<DocumentSnapshot>? snapshot, List<String> part, int index) {
    return Row(
        children: snapshot!
            .map((data) => _buildListItemPartecipant(context, data, part, index))
            .toList());
  }

  Widget _buildListItemPartecipant(BuildContext context, DocumentSnapshot snapshot,
      List<String> part, int index) {
    final user = UserAccount.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    String name;
    String? photo;
    String id;

    if (currentUser != null && index == 2 && part.isNotEmpty) {
      if (user.userid == part.first) {
        name = user.name;
        photo = user.photoUrl;
        id = user.userid as String;
        part.removeAt(0);
        return createButton(name, photo as String, id);
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildListCheck(BuildContext context, List<DocumentSnapshot>? snapshot, String user) {
    return Column(
      children: snapshot!
          .map((data) => _buildListItemCheck(context, data, user))
          .toList(),
    );
  }

  Widget _buildListItemCheck(BuildContext context, DocumentSnapshot snapshot, String user) {
    final list = Check.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (user != 'group' && list.creator == currentUser.uid && !list.isgroup && list.trav == widget.trav.referenceId) {
        return Column( children: [ 
          CheckboxListTile(
            value: list.isChecked, 
            onChanged:(bool? value) {
              updateItem('isChecked', value!, list.referenceId as String);
            },
            title: Text(list.name),
          ),
          const Divider(height: 0),
        ]);
      } else {
        if (user == 'group' && list.isgroup && list.trav == widget.trav.referenceId){
          return Column( children: [ 
            CheckboxListTile(
              value: list.isChecked, 
              onChanged:(bool? value) {
                updateItem('isChecked', value!, list.referenceId as String);
              },
              title: Text(list.name),
            ),
            const Divider(height: 0),
          ]);
        }
      }
    }
    return const SizedBox.shrink();
  }

}


List<String> parts(AsyncSnapshot<QuerySnapshot> snapshot, String name) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final travel = snapshot.data!.docs;
  List<String> partecipantId = [];
  for (var i = 0; i < travel.length; i++) {
    if (travel[i]['name'] == name) {
      for (var x = 0; x < travel[i]['list part'].length; x++) {
        if (travel[i]['list part'][x] != currentUser.uid) {
          partecipantId.add(travel[i]['list part'][x]);
        }
      }
    }
  }
  return partecipantId;
}

bool _hasDataList(AsyncSnapshot<QuerySnapshot> snapshot, String type) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final listitem = snapshot.data!.docs;
  for (var i = 0; i < listitem.length; i++) {
    if(type == 'group'){
      if (listitem[i]['isgroup']) {
        return true;
      }
    } else {
      if (listitem[i]['creator'] == currentUser.uid && !listitem[i]['isgroup']) {
        return true;
      }
    }
  }
  return false;
}