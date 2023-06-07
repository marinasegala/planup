import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/model/user_account.dart';
import 'package:planup/show/statistic_card.dart';
import 'package:planup/show/timeline_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  TravelRepository travelRepository = TravelRepository();

  int friends = 0;
  int travels = 0;
  int places = 0;

  List<Travel> pastTravels = [];

  // get all the past travels of currentuser
  void getPastTravels() {
    var currentMonth = DateTime.now().month.toString().length == 1
        ? "0${DateTime.now().month}"
        : DateTime.now().month;
    var currentDay = DateTime.now().day.toString().length == 1
        ? "0${DateTime.now().day}"
        : DateTime.now().day;
    var currentDate = '${DateTime.now().year}-$currentMonth-$currentDay';
    travelRepository.getStream().listen((event) {
      setState(() {
        pastTravels = event.docs
            .map((snapshot) => Travel.fromSnapshot(snapshot))
            .where((element) =>
                element.userid == widget.friend.userid &&
                element.date != "Giornata" &&
                element.date != "Weekend" &&
                element.date != "Settimana" &&
                element.date != "Altro" &&
                element.date!.compareTo(currentDate) < 0)
            .toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    name = widget.friend.name;
    profilePhoto = widget.friend.photoUrl;

    _getLengthFriends();
    _getLengthTravels();
    _getLengthPlaces();
    getPastTravels();
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

  void _getLengthTravels() async {
    var travelsList = FirebaseFirestore.instance.collection('travel').get();
    travelsList.then((value) {
      for (var element in value.docs) {
        for (var partecipant in element['list part']) {
          if (partecipant == widget.friend.userid) {
            setState(() {
              travels++;
            });
          }
        }
      }
    });
  }

  void _getLengthPlaces() async {
    var placesList =
        await FirebaseFirestore.instance.collection('places').get();
    final int count = placesList.docs
        .where((element) => element['userid'] == widget.friend.userid)
        .length;
    setState(() {
      places = count;
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            profilePhoto != null
                ? ClipOval(
                    child: Material(
                      child: Image.network(
                        profilePhoto as String,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Material(
                      shape: CircleBorder(
                          side: BorderSide(color: Colors.black, width: 1)),
                      child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height * 0.02),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )),
                    ),
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(widget.friend.name,
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)!.friendStatistics,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatisticCard(
                  statisticTitle: 'Amici',
                  statisticValue: friends,
                ),
                StatisticCard(
                  statisticTitle: 'Viaggi',
                  statisticValue: travels,
                ),
                StatisticCard(
                  statisticTitle: 'Posti',
                  statisticValue: places,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)!.friendTravels,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.34,
                child: TravelTimeline(pastTravels: pastTravels),
              ),
            )
          ],
        ),
      ),
    );
  }
}
