import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  List<UserAccount> users = [];

  void getUsers() {
    userRepository.getStream().listen((event) {
      users = event.docs
          .map((e) => UserAccount.fromSnapshot(e))
          .where((element) =>
              element.userid != FirebaseAuth.instance.currentUser!.uid)
          .toList();
    });
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  late String? profilePhoto;
  int travels = 0;
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      for (final providerProfile in currentUser!.providerData) {
        profilePhoto = providerProfile.photoURL;
      }
    }
    // getUsers();
  }

  @override
  Widget build(BuildContext context) {
    print(travels);
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
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    //TODO
                  },
                  child: CircleAvatar(
                      radius: (30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          profilePhoto as String,
                          fit: BoxFit.fitHeight,
                        ),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('La mia lista')
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    //TODO
                  },
                  child: CircleAvatar(
                      radius: (30),
                      backgroundColor: const Color.fromARGB(255, 157, 191, 208),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Icon(
                            Icons.groups_outlined,
                            size: 37,
                          ))),
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
            Container(
              width: 160.0,
              color: Colors.green,
            ),
            Container(
              width: 160.0,
              color: Colors.yellow,
            ),
            Container(
              width: 160.0,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
