import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import '../db/users_rep.dart';
import '../model/travel.dart';
import '../model/user_account.dart';

// ignore: must_be_immutable
class ItemCheckList extends StatefulWidget {
  Travel trav;
  ItemCheckList({Key? key, required this.trav}) : super(key: key);

  @override
  State<ItemCheckList> createState() => _CheckListState();
}

class _CheckListState extends State<ItemCheckList> {
  final UsersRepository userRepository = UsersRepository();
  final TravelRepository travRepository = TravelRepository();

  late List<UserAccount> users;
  late List<String> otherPart = [];

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
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        height: 100.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            const SizedBox(
              width: 10,
            ),
            createButton('La mia lista', profilePhoto as String),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                FloatingActionButton(
                  elevation: 0,
                  onPressed: () {},
                  backgroundColor: const Color.fromARGB(255, 100, 146, 164),
                  foregroundColor: const Color.fromARGB(255, 248, 247, 251),
                  child: const Icon(
                    Icons.groups_outlined,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(widget.trav.name)
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            widget.trav.userid != currentUser!.uid
                ? StreamBuilder<QuerySnapshot>(
                    stream: userRepository.getStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Text("Loading..."));
                      } else {
                        return _buildList(
                            context, snapshot.data!.docs, [''], 1);
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
                    if (otherPart.isNotEmpty) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: userRepository.getStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: Text("Loading..."));
                            } else {
                              return _buildList(
                                  context, snapshot.data!.docs, otherPart, 2);
                            }
                          });
                      // _buildItemPart(otherPart);
                    }
                    return const SizedBox.shrink();
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget createButton(String name, String photo) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: CircleAvatar(
              radius: 28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(photo, fit: BoxFit.fitHeight),
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(name)
      ],
    );
  }

  // Widget _buildItemPart(List<String> otherPart){
  //   print('ciao3');
  //   StreamBuilder<QuerySnapshot>(
  //     stream: userRepository.getStream(),
  //     builder: (context, snapshot) {
  //       print('ciao2');
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: Text("Loading..."));
  //       } else {
  //         print('2 other partecipant: $otherPart -- ${otherPart.first}');
  //         return _buildList(context, snapshot.data!.docs, otherPart, 2);
  //       }
  //   });
  //   return SizedBox.shrink();
  // }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot,
      List<String> part, int index) {
    return Column(
        children: snapshot!
            .map((data) => _buildListItem(context, data, part, index))
            .toList());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot,
      List<String> part, int index) {
    final user = UserAccount.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    String name;
    String? photo;

    if (currentUser != null && index == 1) {
      if (user.userid == widget.trav.userid) {
        return createButton(user.name, user.photoUrl as String);
      }
    }
    if (currentUser != null && index == 2 && part.isNotEmpty) {
      print('part1 $part');
      print('ciao: ${part.first}');
      if (user.email == part.first) {
        name = user.name;
        photo = user.photoUrl;
        part.removeAt(0);
        return createButton(name, photo as String);
      }
    }
    return SizedBox.shrink();
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
