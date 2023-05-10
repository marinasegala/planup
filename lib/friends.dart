import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/friend.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<Friend> users = [];
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        for (final providerProfile in user.providerData) {
          users.add(providerProfile.displayName as Friend);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Cerca amici"), actions: <Widget>[
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: FriendSearch());
            }),
      ]),
    );
  }
}

class FriendSearch extends SearchDelegate<String> {
  final users = [
    Friend('Mario Rossi', userid: '1'),
    Friend('Luigi Verdi', userid: '2'),
    Friend('Giovanni Bianchi', userid: '3'),
    Friend('Giuseppe Neri', userid: '4'),
  ];

  final recentUsers = [
    Friend('Mario Rossi', userid: '1'),
    Friend('Luigi Verdi', userid: '2'),
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Card(
        color: Colors.lightBlue.shade100,
        child: Center(child: Text(query)),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = query.isEmpty
        ? recentUsers
        : users.where((element) => element.name.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        leading: const Icon(Icons.person),
        title: RichText(
            text: TextSpan(
                text: suggestion[index].name.substring(0, query.length),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                text: suggestion[index].name.substring(query.length),
                style: const TextStyle(color: Colors.grey),
              )
            ])),
      ),
      itemCount: suggestion.length,
    );
  }
}
