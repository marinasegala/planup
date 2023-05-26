import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/shopping_rep.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/travel.dart';
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
  final TravelRepository travelRepository = TravelRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  List<Travel> pastTravels = [];

  // get all the past travels of currentuser
  void getPastTravels() {
    var currentMonth = DateTime.now().month.toString().length == 1
        ? "0${DateTime.now().month}"
        : DateTime.now().month;
    var currentDate =
        '${DateTime.now().year}-$currentMonth-${DateTime.now().day}';
    travelRepository.getStream().listen((event) {
      pastTravels = event.docs
          .map((snapshot) => Travel.fromSnapshot(snapshot))
          .where((element) =>
              element.userid == currentUser!.uid &&
              element.date != "Giornata" &&
              element.date != "Weekend" &&
              element.date != "Settimana" &&
              element.date != "Altro" &&
              element.date!.compareTo(currentDate) < 0)
          .toList();
    });
    for (final travel in pastTravels) {
      print(travel);
      print("done");
    }
  }

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

    getPastTravels();
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
                context.pushNamed('setting_profile');
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
                child: TravelTimeline(pastTravels: pastTravels)),
          ),
        ],
      ),
    );
  }
}

class TravelTimeline extends StatelessWidget {
  TravelTimeline({super.key, required this.pastTravels});

  final List<Travel> pastTravels;

  TravelRepository travelRepository = TravelRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Timeline.builder(
        itemBuilder: (BuildContext context, int index) {
          return TimelineModel(TimelineCard(travel: pastTravels[index]),
              icon: const Icon(Icons.flight), iconBackground: Colors.blueGrey);
        },
        itemCount: pastTravels.length,
        physics: const ClampingScrollPhysics(),
        position: TimelinePosition.Left,
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(travel.name, style: const TextStyle(fontSize: 16)),
        subtitle:
            Text(travel.date as String, style: const TextStyle(fontSize: 12)),
        trailing: travel.photo!.isEmpty
            ? Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.photo),
              )
            : Image.network(travel.photo!),
      ),
    );
  }
}
