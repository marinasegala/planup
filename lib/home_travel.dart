import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_travel.dart';

import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/travel.dart';

import 'show/trav_card.dart';

class HomeTravel extends StatefulWidget {
  const HomeTravel({super.key});

  @override
  State<HomeTravel> createState() => _HomeTravelState();
}

class _HomeTravelState extends State<HomeTravel> {
  final DataRepository repository = DataRepository();

  final boldStyle =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    // final trav = Travel.fromSnapshot(snapshot);
    // if (FirebaseAuth.instance.currentUser != null) {
    //   if (trav.userid == FirebaseAuth.instance.currentUser?.uid){
    //     return TravCard(trav: trav, boldStyle: boldStyle );
    //   }
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text('I tuoi viaggi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            } else {
              final hasMyOnwTravel = _hasMyOnwTravel(snapshot);
              if (!hasMyOnwTravel) {
                return _noItem();
              } else {
                return _buildList(context, snapshot.data!.docs);
              }
            }
          }),

      // // An example of the floating action button.
      // //
      // // https://m3.material.io/components/floating-action-button/specs

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTravelPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _noItem() {
    //TODO: sistemare perche non va
    return const Center(child: Text('Non hai viaggi'));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final trav = Travel.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (trav.userid == FirebaseAuth.instance.currentUser?.uid) {
        return TravCard(trav: trav, boldStyle: boldStyle);
      }
    }
    return const SizedBox.shrink();
  }
}

// function that return if there is a travel created by the user
bool _hasMyOnwTravel(AsyncSnapshot<QuerySnapshot> snapshot) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final trav = snapshot.data!.docs;
  for (var i = 0; i < trav.length; i++) {
    if (trav[i]['userid'] == currentUser.uid) {
      return true;
    }
  }
  return false;
}
