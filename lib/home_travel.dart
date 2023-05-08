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
  
  final boldStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  bool _searchBoolean = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_searchBoolean ? const Text('I tuoi viaggi') : _searchTextField(),
        actions: !_searchBoolean
        ? [ IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() { 
                  _searchBoolean = true; 
              });}
          )] 
        : [ IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchBoolean = false;
              });}
          )]
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();
          return _buildList(context, snapshot.data?.docs ?? []);
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

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  } 

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final trav = Travel.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (trav.userid == FirebaseAuth.instance.currentUser?.uid){
        return TravCard(trav: trav, boldStyle: boldStyle );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _searchTextField() {
    return const TextField(
      autofocus: true, //Display the keyboard when TextField is displayed
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //Specify the action button on the keyboard
      decoration: InputDecoration( //Style of TextField
        enabledBorder: UnderlineInputBorder( //Default TextField border
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //Borders when a TextField is in focus
          borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'Search', //Text that is displayed when nothing is entered.
        hintStyle: TextStyle( //Style of hintText
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }

}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // The search area here
          title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    /* Clear the search field */
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none),
          ),
        ),
      )),
    );
  }
}