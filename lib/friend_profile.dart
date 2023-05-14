import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/userAccount.dart';
import 'package:planup/widgets/statistic_card.dart';

class FriendProfile extends StatefulWidget {
  const FriendProfile({super.key, required this.friend});

  final UserAccount friend;

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  late UserAccount friendUser;
  String? name;
  String? profilePhoto;

  int friends = 0;
  int travels = 0;

  @override
  void initState() {
    super.initState();

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
            Text(widget.friend.name, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Text("Le statistiche di ${widget.friend.name}",
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
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
