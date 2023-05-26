import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/checklist.dart';

import '../db/checklist_rep.dart';
import '../db/users_rep.dart';
import '../model/travel.dart';
import '../model/user_account.dart';

class ItemCheckList extends StatefulWidget {
  Travel trav;
  ItemCheckList({Key? key, required this.trav}) : super(key: key);

  @override
  State<ItemCheckList> createState() => _CheckListState();
}

class _CheckListState extends State<ItemCheckList>{
  final UsersRepository userRepository = UsersRepository();
  final TravelRepository travRepository = TravelRepository();
  
  late List<UserAccount> users;
  late List<String> otherPart = [];
  bool isChecked = false;

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
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Check List'),
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          height: 100.0,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                const SizedBox(width: 10,),
                createButton('La mia lista', profilePhoto as String),
                
                Column(children: [
                  FloatingActionButton(
                    elevation: 0,
                    onPressed: () {
                    },
                    backgroundColor: const Color.fromARGB(255, 100, 146, 164),
                    foregroundColor: const Color.fromARGB(255, 248, 247, 251),
                    child: const Icon(Icons.groups_outlined, size: 30,),
                  ),
                  const SizedBox(height: 10,),
                  Text(widget.trav.name)
                ],),
                const SizedBox(width: 10,),
                
                widget.trav.userid != currentUser!.uid
                  ? StreamBuilder<QuerySnapshot>(
                        stream: userRepository.getStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Text("Loading..."));
                          } else {
                            return _buildListPart(context, snapshot.data!.docs, [''], 1);
                          }
                      })
                  : const SizedBox.shrink(),

                StreamBuilder<QuerySnapshot>(
                  stream: travRepository.getStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    } else {
                      otherPart = parts(snapshot, widget.trav.name);
                      if (otherPart.isNotEmpty){
                        return StreamBuilder<QuerySnapshot>(
                          stream: userRepository.getStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: Text("Loading..."));
                            } else {
                              return _buildListPart(context, snapshot.data!.docs, otherPart, 2);
                            }
                          });
                      }
                      return const SizedBox.shrink();
                    }
                }),
                
              ],
            ),
        ),
        
        StreamBuilder<QuerySnapshot>(
          stream: ListRepository().getStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            } else {
              final hasMyOnwData = _hasMyOnwData(snapshot, widget.trav.name);
              if (!hasMyOnwData) {
                return _noItem();
              } else {
                return Text(widget.trav.name);
                // return _buildList(context, snapshot.data!.docs, widget.trav);
              }
            }
        }),
      
      
      ],),
      
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
  
  Widget createButton(String name, String photo) {
    return Row(children: [ 
      Column( children: [
        GestureDetector(
          onTap: (){},
          child: CircleAvatar(
              radius: 28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50), 
                child: Image.network( photo, fit: BoxFit.fitHeight),
              )
            ),
        ),
        const SizedBox(height: 10,),
        Text(name)
      ],),
      const SizedBox(width: 10,)
    ],);
    
  }

  Widget _buildListPart(BuildContext context, List<DocumentSnapshot>? snapshot, List<String> part, int index) {
    return Column(children: snapshot!.map((data) => _buildListItemPart(context, data, part, index)).toList()); 
  }

  Widget _buildListItemPart(BuildContext context, DocumentSnapshot snapshot, List<String> part, int index) {
    final user = UserAccount.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    String name ;
    String? photo;
    
    if (currentUser != null && index == 1) {
      if (user.userid == widget.trav.userid) {
        return createButton(user.name, user.photoUrl as String);
      }
    }
    if (currentUser != null && index == 2 && part.isNotEmpty) {
      if(user.email == part.first){
        name = user.name;
        photo = user.photoUrl;
        part.removeAt(0);
        return createButton(name, photo as String);
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot, Travel travel) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children:
          snapshot!.map((data) => _buildListItem(context, data, travel)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot, Travel travel) {
    final item = Check.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (item.userid == FirebaseAuth.instance.currentUser?.uid && item.trav == travel.name) {
        // return Column(children: [
        //   Row(children: [ Checkbox(
        //     checkColor: Colors.white,
        //     // fillColor: MaterialStateProperty.resolveWith(getColor),
        //     value: isChecked,
        //     onChanged: (bool? value) {
        //       setState(() {
        //         isChecked = value!;
        //       });
        //     },),
        //     Text(item.name),
        //   ]),
        //   const Divider(height: 0),
        // ],);
        return Text(item.name);
      }
    }
    return const SizedBox.shrink();
  }
  

}

bool _hasMyOnwData(AsyncSnapshot<QuerySnapshot> snapshot, String? name) {
  bool datas = false;
  final checks = snapshot.data!.docs;
  for (var i = 0; i < checks.length; i++) {
    if (checks[i]['trav'] == name as String) {
      datas = true;
      return datas;
    }
  }
  return datas;
}

List<String> parts(AsyncSnapshot<QuerySnapshot> snapshot, String name) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final travel = snapshot.data!.docs;
  List<String> emails = [];
  for (var i = 0; i < travel.length; i++) {
    if(travel[i]['name'] == name){
      for (var x = 0; x < travel[i]['list part'].length; x++) {
        if (travel[i]['list part'][x] != currentUser.email) {
          emails.add(travel[i]['list part'][x]);
        }
      }
    }
  }
  return emails;
}