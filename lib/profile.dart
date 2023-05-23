import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/shopping_rep.dart';
import 'package:planup/setting_profile.dart';
import 'package:planup/show/statistic_card.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

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
  int places = 0;

  final FriendsRepository friendRepository = FriendsRepository();
  final ShopRepository dataRepository = ShopRepository();
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
    _getLengthTravels();

    // get the number of places of currentuser from the list of places
    _getLengthPlaces();
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

  void _getLengthTravels() async {
    var travelsList =
        await FirebaseFirestore.instance.collection('travel').get();
    final int count = travelsList.docs
        .where((element) => element['userid'] == currentUser!.uid)
        .length;
    setState(() {
      travels = count;
    });
  }

  void _getLengthPlaces() async {
    var placesList =
        await FirebaseFirestore.instance.collection('places').get();
    final int count = placesList.docs
        .where((element) => element['userid'] == currentUser!.uid)
        .length;
    setState(() {
      places = count;
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
              StatisticCard(
                statisticTitle: "Posti",
                statisticValue: places,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text("I tuoi viaggi", style: TextStyle(fontSize: 12))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: const TravelTimeline()),
          ),
        ],
      ),
    );
  }
}

class TravelTimeline extends StatelessWidget {
  const TravelTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Timeline(
        position: TimelinePosition.Left,
        iconSize: 20,
        children: <TimelineModel>[
          TimelineModel(
            const SizedBox(
              height: 100,
              child: Center(
                child: Text("Timeline"),
              ),
            ),
            icon: const Icon(Icons.timeline),
          ),
          TimelineModel(
            const SizedBox(
              height: 100,
              child: Center(
                child: Text("Timeline"),
              ),
            ),
            icon: const Icon(Icons.timeline),
          ),
          TimelineModel(
            const SizedBox(
              height: 100,
              child: Center(
                child: Text("Timeline"),
              ),
            ),
            icon: const Icon(Icons.timeline),
          )
        ]);
  }
}
