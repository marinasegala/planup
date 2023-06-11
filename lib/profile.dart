import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/shopping_rep.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/show/statistic_card.dart';
import 'package:planup/show/timeline_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'db/authentication_service.dart';
import 'login.dart';
import 'model/user_account.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int friends = 0;
  int travels = 0;
  int places = 0;

  List<String> friendsId = [];
  List<String> asFriend = [];
  List<String> listid = [];

  final FriendsRepository friendRepository = FriendsRepository();
  final ShopRepository dataRepository = ShopRepository();
  final TravelRepository travelRepository = TravelRepository();
  final currentUser = FirebaseAuth.instance.currentUser;
  late List<UserAccount> users = [];
  final UsersRepository usersRepository = UsersRepository();

  List<Travel> pastTravels = [];
  List<Travel> pastTrav = [];

  late String? name;
  late String? profilePhoto;
  late List<String> usersId = [];

  bool getId(Travel element, String currentDate){
    FirebaseFirestore.instance.collection('travel')
    .doc(element.referenceId)
    .get()
    .then((querySnapshot){ //14 alla fine o 0-10
      for(var x in querySnapshot.get('list part')){
        
        
        if(x==currentUser?.uid &&
          element.date != "Giornata" &&
          element.date != "Weekend" &&
          element.date != "Settimana" &&
          element.date != "Altro")
        {
          var controlDate = 
          element.date!.length>14
          ? element.date!.substring(15,25)
          : element.date!;
          print('${controlDate} - ${element.name}');
          print(currentDate);
          if (controlDate.compareTo(currentDate) < 0){
            print(element.name);
            setState(() {
              pastTrav.add(element);
            });
            return true;
            }
        }
      }
    });
    return false;
  }

  void getUsers() {
    // obtain users from the repository and add to the list
    usersRepository.getUsers().then((usersList) {
      setState(() {
        users = usersList;
      });
    });
  }

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
      pastTravels = event.docs
          .map((snapshot) => Travel.fromSnapshot(snapshot))
          .where((element) =>
            getId(element, currentDate)
          )
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();

    name = currentUser!.displayName;
    profilePhoto = currentUser!.photoURL;

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
    friendsList.then((value) {
      final int count = value.docs
          .where((element) => element['userIdFriend'] == currentUser!.uid)
          .length;
      setState(() {
        friends = count>friends ? friends : count ;
      });
    });
  }

   get(String where, String add) {
    FirebaseFirestore.instance
        .collection('friends')
        .where(where, isEqualTo: currentUser?.uid)
        .get()
        .then(
      (querySnapshot) {
        // print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          if (where == 'userid') {
            friendsId.add(docSnapshot.get(add));
          } else {
            asFriend.add(docSnapshot.get(add));
          }
        }
      },
    );
  }

  getfinal() {
    for (var id in friendsId) {
      if (asFriend.contains(id) && !listid.contains(id)) {
        listid.add(id);
      }
    }
  }

  

  void _getLengthTravels() async {
    // get the number of travels in which the currentuser has participated
    var travelsList = FirebaseFirestore.instance.collection('travel').get();
    travelsList.then((value) {
      for (var element in value.docs) {
        for (var partecipant in element['list part']) {
          if (partecipant == currentUser!.uid) {
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
        title: Text(AppLocalizations.of(context)!.myProfile),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text(AppLocalizations.of(context)!.sureToExit),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'No'),
                            child: Text(AppLocalizations.of(context)!.no),
                          ),
                          TextButton(
                            onPressed: () {
                              AuthenticationServices().signOut();
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => const LoginPage()));
                            },
                            child: Text(AppLocalizations.of(context)!.yes),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.logout_outlined,
                size: 30,
              ))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.2),
                      child: Icon(
                        Icons.person,
                        size: 60,
                      ),
                    ),
                  ),
                ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(name!, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)!.myStatistics,
                    style: const TextStyle(fontSize: 15))),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)!.numFriend,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic))),
          ),
          // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: Row(children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(AppLocalizations.of(context)!.myTravels,
                    style: const TextStyle(fontSize: 15))
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(AppLocalizations.of(context)!.infoTravelTimeline),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: Theme.of(context).textTheme.bodyMedium,
                              ),
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () { Navigator.of(context).pop(); },
                            ),
                          ],
                        );
                      },
                    );
                  }, 
                  icon: Icon(Icons.help_outline_outlined, size: 20,)),
              )
              
            ],)
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02),
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.34,
                child: TravelTimeline(pastTravels: pastTrav)),
          ),
        ],
      ),
    );
  }
}
