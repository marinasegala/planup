import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crea_radio_button/crea_radio_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import '../db/checklist_rep.dart';
import '../db/users_rep.dart';
import '../model/checklist.dart';
import '../model/travel.dart';
import '../model/user_account.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class ItemCheckList extends StatefulWidget {
  Travel trav;
  final bool isPast;
  ItemCheckList({Key? key, required this.trav, required this.isPast}) : super(key: key);

  @override
  State<ItemCheckList> createState() => _CheckListState();
}

class _CheckListState extends State<ItemCheckList> {
  final ListRepository repository = ListRepository();
  final UsersRepository userRepository = UsersRepository();
  final TravelRepository travRepository = TravelRepository();

  late List<String> otherPart = [];
  late List<UserAccount> useraccount = [];

  String stateItem = "Privato";

  late String current = currentUser?.uid as String;
  late String currentName = 'My List';

  final currentUser = FirebaseAuth.instance.currentUser;
  late String? profilePhoto;

  String nameItem = '';
  String typeItem = '';

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      for (final providerProfile in currentUser!.providerData) {
        profilePhoto = providerProfile.photoURL;
      }
    }
  }

  Future<void> updateItem(String field, String newField, String id) {
    return FirebaseFirestore.instance
        .collection('check')
        .doc(id)
        .update({field: newField}).then((value) => print("Update"),
            onError: (e) => print("Error updating doc: $e"));
  }

  Future<void> updateIsChecked(String field, bool newField, String id) {
    return FirebaseFirestore.instance
        .collection('check')
        .doc(id)
        .update({field: newField}).then((value) => print("Update"),
            onError: (e) => print("Error updating doc: $e"));
  }

  Future<void> copyItem(Check list) {
    final newitemList = Check(
      list.name,
      trav: list.trav,
      creator: currentUser?.uid,
      isgroup: false,
      isPublic: true,
      isChecked: false,
      whoBring: 'nil',
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.processingData)));
    return repository.add(newitemList);
  }

  @override
  Widget build(BuildContext context) {
    List<RadioOption> options = [
      // first the value that will be insert in the database, second the label
      RadioOption("Pubblico", AppLocalizations.of(context)!.public),
      RadioOption("Privato", AppLocalizations.of(context)!.private)
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.whatBring),
      ),
      body: ListView(scrollDirection: Axis.vertical, children: [
        Container(
          margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02),
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              createButton(AppLocalizations.of(context)!.myList,
                  profilePhoto as String, currentUser?.uid as String),
              createButton(widget.trav.name, widget.trav.photo as String, 'group'),
              StreamBuilder<QuerySnapshot>(
                  stream: travRepository.getStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: Text(AppLocalizations.of(context)!.loading));
                    } else {
                      otherPart = parts(snapshot, widget.trav.name);
                      if (otherPart.isNotEmpty) {
                        return StreamBuilder<QuerySnapshot>(
                            stream: userRepository.getStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: Text(
                                        AppLocalizations.of(context)!.loading));
                              } else {
                                return _buildListPartecipant(
                                    context, snapshot.data!.docs, otherPart, 2);
                              }
                            });
                      }
                      return const SizedBox.shrink();
                    }
                  }),
            ],
          ),
        ),
        _title(currentName),
        current == currentUser?.uid
            ? Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  widget.isPast
                  ? const SizedBox.shrink()
                  : Text(
                    AppLocalizations.of(context)!.publicObjects,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: ListRepository().getStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: Text(AppLocalizations.of(context)!.loading));
                      } else {
                        return _buildListCheck(
                            context, snapshot.data!.docs, current, true);
                      }
                    },
                  )
                ],
              )
            : current == 'group'
                ? Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: ListRepository().getStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Text(
                                    AppLocalizations.of(context)!.loading));
                          } else {
                            return _buildListCheck(
                                context, snapshot.data!.docs, current, true);
                          }
                        },
                      )
                    ],
                  )
                : Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: ListRepository().getStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Text(
                                    AppLocalizations.of(context)!.loading));
                          } else {
                            final hasDataList =
                                _hasDataList(snapshot, 'personal', false);

                            if (!hasDataList) {
                              return _noItem();
                            } else {
                              return _buildListCheck(
                                  context, snapshot.data!.docs, current, false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
      ]),
      floatingActionButton: 
      current == currentUser?.uid && !widget.isPast
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text(AppLocalizations.of(context)!.newObject),
                        content: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.nameObject,
                                ),
                                onChanged: (text) => nameItem = text,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              RadioButtonGroup(
                                  options: options,
                                  preSelectedIdx: 1,
                                  textStyle: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  selectedColor:
                                      const Color.fromARGB(255, 195, 190, 190),
                                  mainColor:
                                      const Color.fromARGB(255, 195, 190, 190),
                                  selectedBorderSide: const BorderSide(
                                      color: Color.fromARGB(255, 64, 137, 168)),
                                  buttonWidth:
                                      MediaQuery.of(context).size.width * 0.26,
                                  buttonHeight:
                                      MediaQuery.of(context).size.height * 0.05,
                                  callback: (RadioOption val) {
                                    setState(() {
                                      stateItem = val.label;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              child: Text(AppLocalizations.of(context)!.send),
                              onPressed: () {
                                final newitemList = Check(
                                  nameItem,
                                  trav: widget.trav.referenceId,
                                  creator: currentUser?.uid,
                                  isgroup: false,
                                  isPublic:
                                      stateItem == 'Pubblico' ? true : false,
                                  isChecked: false,
                                  whoBring: 'nil',
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
          : current == 'group' && !widget.isPast
              ? FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            title:
                                Text(AppLocalizations.of(context)!.newObject),
                            content: Padding(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.height * 0.01),
                              child: Form(
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .nameObject,
                                      ),
                                      onChanged: (text) => nameItem = text,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                  child:
                                      Text(AppLocalizations.of(context)!.send),
                                  onPressed: () {
                                    final newitemList = Check(
                                      nameItem,
                                      trav: widget.trav.referenceId,
                                      creator: currentUser?.uid,
                                      isgroup: true,
                                      isPublic: false,
                                      isChecked: false,
                                      whoBring: '',
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
    return Center(
        child: Text(
      AppLocalizations.of(context)!.noObjects,
      style: const TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    ));
  }

  Widget createButton(String name, String photo, String id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      onPressed: () {
        setState(() {
          current = id;
          currentName = name;
          if (name == widget.trav.name) {
            currentName = 'group';
          }
        });
      },
      child: Column(children: [
        name == widget.trav.name && photo == ''
          ? CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.08,
                  child: Icon(
                    Icons.group_outlined,
                    size: MediaQuery.of(context).size.width * 0.1,
                  ),
                )
          : CircleAvatar(
                backgroundImage: NetworkImage(photo),
                radius: MediaQuery.of(context).size.width * 0.08,
              ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          name,
          style: const TextStyle(color: Colors.black),
        )
      ]),
    );
  }

  Widget _buildListPartecipant(BuildContext context,
      List<DocumentSnapshot>? snapshot, List<String> part, int index) {
    return Row(
        children: snapshot!
            .map(
                (data) => _buildListItemPartecipant(context, data, part, index))
            .toList());
  }

  Widget _buildListItemPartecipant(BuildContext context,
      DocumentSnapshot snapshot, List<String> part, int index) {
    final user = UserAccount.fromSnapshot(snapshot);
    useraccount.add(user);
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

  Widget _buildListCheck(BuildContext context, List<DocumentSnapshot>? snapshot,
      String user, bool bool) {
    return Column(
      children: snapshot!
          .map((data) => _buildListItemCheck(context, data, user, bool))
          .toList(),
    );
  }

  Widget _buildListItemCheck(BuildContext context, DocumentSnapshot snapshot,
      String userid, bool userCurrent) {
    final list = Check.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (userid != 'group' &&
          list.creator == userid &&
          !list.isgroup &&
          list.trav == widget.trav.referenceId) {
        if (userCurrent) {
          return Column(children: [
            CheckboxListTile(
                value: list.isChecked,
                onChanged: (bool? value) {
                  updateIsChecked(
                      'isChecked', value!, list.referenceId as String);
                },
                title: Text(list.name),
                subtitle: Text(list.isPublic
                    ? AppLocalizations.of(context)!.public
                    : AppLocalizations.of(context)!.private),
                secondary: !list.isChecked
                    ? IconButton(
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('check')
                              .doc(list.referenceId)
                              .get()
                              .then((querySnapshot) {
                            delete(querySnapshot.id);
                          });
                        })
                    : const SizedBox.shrink()),
            const Divider(height: 0),
          ]);
        } else {
          if (list.isPublic) {
            return Column(children: [
              ListTile(
                title: Text(list.name),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      copyItem(list);
                    });
                  },
                ),
              ),
              const Divider(height: 0),
            ]);
          }
        }
      } else {
        if (userid == 'group' &&
            list.isgroup &&
            list.trav == widget.trav.referenceId) {
          return Column(children: [
            CheckboxListTile(
                value: list.isChecked,
                onChanged: (bool? value) {
                  if (value == false && list.whoBring == currentUser.uid) {
                    updateItem('whoBring', '', list.referenceId as String);
                    updateIsChecked(
                        'isChecked', value!, list.referenceId as String);
                  }
                  if (value == true) {
                    updateItem('whoBring', currentUser.uid,
                        list.referenceId as String);
                    updateIsChecked(
                        'isChecked', value!, list.referenceId as String);
                  }
                },
                title: Text(list.name),
                secondary: !list.isChecked
                    ? IconButton(
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('check')
                              .doc(list.referenceId)
                              .get()
                              .then((querySnapshot) {
                            delete(querySnapshot.id);
                          });
                        })
                    : const SizedBox.shrink(),
                subtitle: list.whoBring != ''
                    ? StreamBuilder<QuerySnapshot>(
                        stream: userRepository.getStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Text(
                                    AppLocalizations.of(context)!.loading));
                          } else {
                            return _textWhoBring(snapshot, list.whoBring);
                          }
                        },
                      )
                    : const Text('')),
            const Divider(height: 0),
          ]);
        }
      }
    }
    return const SizedBox.shrink();
  }

  Future<void> delete(String id) {
    return FirebaseFirestore.instance.collection("check").doc(id).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }

  Widget _title(String list) {
    String nameTitle;
    switch (list) {
      case 'group':
        nameTitle = AppLocalizations.of(context)!.groupList;
        break;
      case 'My List':
        nameTitle = AppLocalizations.of(context)!.myList;
        break;
      default:
        nameTitle = AppLocalizations.of(context)!.checkList(list);
    }
    return Text(
      nameTitle,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _textWhoBring(AsyncSnapshot<QuerySnapshot> snapshot, String whoBring) {
    final user = snapshot.data!.docs;
    for (var i = 0; i < user.length; i++) {
      if (user[i]['userid'] == whoBring) {
        return Text(AppLocalizations.of(context)!.bringBy(user[i]['name']));
      }
    }
    return const Text('');
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

bool _hasDataList(
    AsyncSnapshot<QuerySnapshot> snapshot, String type, bool bool) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final listitem = snapshot.data!.docs;
  for (var i = 0; i < listitem.length; i++) {
    if (type == 'group') {
      if (listitem[i]['isgroup']) {
        return true;
      }
    }
    if (type != 'group' && bool) {
      if (listitem[i]['creator'] == currentUser.uid &&
          !listitem[i]['isgroup']) {
        return true;
      }
    }
    if (type != 'group' && !bool) {
      if (listitem[i]['creator'] != currentUser.uid &&
          !listitem[i]['isgroup'] &&
          listitem[i]['isPublic']) {
        return true;
      }
    }
  }
  return false;
}
