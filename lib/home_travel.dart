import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/create_travel.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/travel.dart';
import 'show/trav_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeTravel extends StatefulWidget {
  const HomeTravel({super.key});

  @override
  State<HomeTravel> createState() => _HomeTravelState();
}

class _HomeTravelState extends State<HomeTravel> {
  final TravelRepository repository = TravelRepository();

  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTravels),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text(AppLocalizations.of(context)!.loading));
            } else {
              final hasMyOwnTravel = _hasMyOwnTravel(snapshot);
              if (!hasMyOwnTravel) {
                return _noItem();
              } else {
                return _buildList(context, snapshot.data!.docs, snapshot);
              }
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateTravelPage()));
        },
        backgroundColor: const Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _noItem() {
    return Center(
        child: Text(
      AppLocalizations.of(context)!.myTravelsEmpty,
      style: const TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    ));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot,
      AsyncSnapshot<QuerySnapshot> querysnapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!
          .map((data) => _buildListItem(context, data, querysnapshot))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot,
      AsyncSnapshot<QuerySnapshot> querysnapshot) {
    final trav = Travel.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    final travels = querysnapshot.data!.docs;
    if (currentUser != null) {
      if (trav.userid == currentUser.uid) {
        return TravCard(trav: trav, boldStyle: boldStyle);
      } else {
        for (var i = 0; i < travels.length; i++) {
          for (var x = 0; x < travels[i]['list part'].length; x++) {
            if (travels[i]['list part'][x] == currentUser.uid &&
                travels[i]['name'] == trav.name) {
              return TravCard(trav: trav, boldStyle: boldStyle);
            }
          }
        }
      }
    }
    return const SizedBox.shrink();
  }
}

// function that return if there is a travel created by the user
bool _hasMyOwnTravel(AsyncSnapshot<QuerySnapshot> snapshot) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final trav = snapshot.data!.docs;
  for (var i = 0; i < trav.length; i++) {
    if (trav[i]['userid'] == currentUser.uid) {
      return true;
    }
    for (var x = 0; x < trav[i]['list part'].length; x++) {
      if (trav[i]['list part'][x] == currentUser.uid) {
        return true;
      }
    }
  }
  return false;
}
