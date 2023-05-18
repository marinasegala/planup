import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/userAccount.dart';
import 'package:planup/show/statistic_card.dart';

class FriendProfile extends StatefulWidget {
  const FriendProfile({super.key, required this.friend});

  final UserAccount friend;

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  String? name;
  String? profilePhoto;

  UsersRepository usersRepository = UsersRepository();
  User currentUser = FirebaseAuth.instance.currentUser!;

  int friends = 0;
  int travels = 0;

  @override
  void initState() {
    super.initState();

    name = widget.friend.name;
    profilePhoto = widget.friend.photoUrl;

    _getLengthFriends();
    _getLengthTraverls();
  }

  void _getLengthFriends() {
    var friendsList = FirebaseFirestore.instance.collection('friends').get();
    friendsList.then((value) {
      final int count = value.docs
          .where((element) => element['userid'] == widget.friend.userid)
          .length;
      setState(() {
        friends = count;
      });
    });
  }

  void _getLengthTraverls() async {
    var travelsList =
        await FirebaseFirestore.instance.collection('travel').get();
    final int count = travelsList.docs
        .where((element) => element['userid'] == widget.friend.userid)
        .length;
    setState(() {
      travels = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Row(),
            const SizedBox(height: 20),
            profilePhoto != null
                ? ClipOval(
                    child: Material(
                      child: Image.network(
                        profilePhoto as String,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : const ClipOval(
                    child: Material(
                      shape: CircleBorder(
                          side: BorderSide(color: Colors.black, width: 1)),
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )),
                    ),
                  ),
            const SizedBox(height: 15),
            Text(widget.friend.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child:
                    Text("Le sue statistiche", style: TextStyle(fontSize: 12)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatisticCard(
                  statisticTitle: "Amici",
                  statisticValue: friends,
                ),
                StatisticCard(
                  statisticTitle: "Viaggi",
                  statisticValue: travels,
                ),
                const StatisticCard(
                  statisticTitle: "Posti",
                  statisticValue: 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
