import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import '../db/checklist_rep.dart';
import '../db/users_rep.dart';
import '../model/checklist.dart';
import '../model/travel.dart';
import '../model/user_account.dart';

// ignore: must_be_immutable
class ItemCheckList extends StatefulWidget {
  Travel trav;
  ItemCheckList({Key? key, required this.trav}) : super(key: key);

  @override
  State<ItemCheckList> createState() => _CheckListState();
}

enum StateList { privata, pubblica }

class _CheckListState extends State<ItemCheckList> {
  final UsersRepository userRepository = UsersRepository();
  final TravelRepository travRepository = TravelRepository();

  late List<UserAccount> users;
  late List<String> otherPart = [];

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  StateList? _statelist = StateList.privata;

  late String list = '';
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
            // child: DefaultTabController(
            //   length: 6, // (widget.trav.numFriend as int) + 1,
            //   child: Column(
            //     children: <Widget>[
            //       ButtonsTabBar(
            //         // backgroundColor: Colors.red,
            //         unselectedBackgroundColor: Colors.transparent,
            //         unselectedLabelStyle: const TextStyle(color: Colors.black),
            //         labelStyle:
            //             const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //         tabs:const [
            //           Tab(
            //             icon: Icon(Icons.directions_car),
            //             text: "car",
            //           ),
            //           Tab(
            //             icon: Icon(Icons.directions_transit),
            //             text: "transit",
            //           ),
            //           Tab(icon: Icon(Icons.directions_bike)),
            //           Tab(icon: Icon(Icons.directions_car)),
            //           Tab(icon: Icon(Icons.directions_transit)),
            //           Tab(icon: Icon(Icons.directions_bike)),
            //         ],
            //       ),
            //       const Expanded(
            //         child: TabBarView(
            //           children: <Widget>[
            //             Center(
            //               child: Icon(Icons.directions_car),
            //             ),
            //             Center(
            //               child: Icon(Icons.directions_transit),
            //             ),
            //             Center(
            //               child: Icon(Icons.directions_bike),
            //             ),
            //             Center(
            //               child: Icon(Icons.directions_car),
            //             ),
            //             Center(
            //               child: Icon(Icons.directions_transit),
            //             ),
            //             Center(
            //               child: Icon(Icons.directions_bike),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                                return _buildListPart(context,
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
          StreamBuilder<QuerySnapshot>(
            stream: ListRepository().getStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {
                return _hasData(snapshot);
              }
            },
          ),

          
        ],
      ),
    );
  }

  Widget _noItem() {
    return const Center(
        child: Text(
      'Non hai ancora inserito gli oggetti da portare',
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

  Widget _buildListPart(BuildContext context, List<DocumentSnapshot>? snapshot, List<String> part, int index) {
    return Row(
        children: snapshot!
            .map((data) => _buildListItemPart(context, data, part, index))
            .toList());
  }

  Widget _buildListItemPart(BuildContext context, DocumentSnapshot snapshot,
      List<String> part, int index) {
    final user = UserAccount.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    String name;
    String? photo;
    String id;

    if (currentUser != null && index == 2 && part.isNotEmpty) {
      if (user.email == part.first) {
        name = user.name;
        photo = user.photoUrl;
        id = user.userid as String;
        part.removeAt(0);
        return createButton(name, photo as String, id);
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildListCheck(
      BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children:
          snapshot!.map((data) => _buildListCheckItem(context, data)).toList(),
    );
  }

  Widget _buildListCheckItem(BuildContext context, DocumentSnapshot snapshot) {
    final list = Check.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (list.userid == currentUser?.uid && !list.isgroup) {
      return Column(
        children: [
          CheckboxListTile(
            value: checkboxValue1,
            onChanged: (bool? value) {
              setState(() {
                checkboxValue1 = value!;
              });
            },
            title: Text(list.name),
          ),
          const Divider(height: 0),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _hasData(AsyncSnapshot<QuerySnapshot> snapshot) {
    final checks = snapshot.data!.docs;
    final currentUser = FirebaseAuth.instance.currentUser;
    for (var i = 0; i < checks.length; i++) {
      if (checks[i]['trav'] == widget.trav.referenceId as String) {
        if (checks[i]['userid'] == currentUser?.uid && !checks[i]['isgroup']) {
          return Column(
            children: [
              CheckboxListTile(
                value: checks[i]['isChecked'],
                onChanged: (bool? value) {
                  updateItem('isChecked', value!, checks[i].id);
                },
                title: Text(checks[i]['name']),
              ),
              const Divider(height: 0),
            ],
          );
        }
      }
    }
    return const SizedBox.shrink();
  }
}

List<String> parts(AsyncSnapshot<QuerySnapshot> snapshot, String name) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final travel = snapshot.data!.docs;
  List<String> emails = [];
  for (var i = 0; i < travel.length; i++) {
    if (travel[i]['name'] == name) {
      for (var x = 0; x < travel[i]['list part'].length; x++) {
        if (travel[i]['list part'][x] != currentUser.email) {
          emails.add(travel[i]['list part'][x]);
        }
      }
    }
  }
  return emails;
}
