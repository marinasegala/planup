import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/shopping_rep.dart';
import 'package:planup/setting_profile.dart';
import 'package:planup/show/statistic_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? name;
  late String? profilePhoto;
  int friends = 0;
  int travels = 0;

  final FriendsRepository friendRepository = FriendsRepository();
  final DataRepository dataRepository = DataRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    if (FirebaseAuth.instance.currentUser != null) {
      for (final providerProfile in currentUser!.providerData) {
        name = providerProfile.displayName;
        profilePhoto = providerProfile.photoURL;
      }
    }

    // get the number of friends of currentuser from the list of friends
    _getLengthFriends();

    // get the number of travels of currentuser from the list of travels
    _getLengthTraverls();
  }

  void _getLengthFriends() {
    var friendsList = FirebaseFirestore.instance.collection('friends').get();
    friendsList.then((value) {
      final int count = value.docs
          .where((element) => element['userid'] == currentUser!.uid)
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
        .where((element) => element['userid'] == currentUser!.uid)
        .length;
    setState(() {
      travels = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Il mio profilo"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsProfile()),
                );
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: [
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
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.person,
                        size: 60,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 15),
          Text(name as String, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
                alignment: Alignment.topLeft,
                child:
                    Text("Le tue statistiche", style: TextStyle(fontSize: 12))),
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
    );
  }
}
