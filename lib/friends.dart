import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage>{
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context){
    List<String> users=[];
    FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
        if (user != null) {
          for (final providerProfile in user.providerData) {
            users.add(providerProfile.displayName as String);
          }
        }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("I miei amici"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          // Add padding around the search bar
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          // Use a Material design search bar
          child: TextField(
            // controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              // Add a clear button to the search bar
              // suffixIcon: IconButton(
              //   icon: const Icon(Icons.clear),
              //   onPressed: () => _searchController.clear(),
              // ),
              // Add a search icon or button to the search bar
              prefixIcon:IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Perform the search here
                  // showSearch(context: context, delegate: SearchFriends());
                },

              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}