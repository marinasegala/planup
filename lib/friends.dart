import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/userAccount.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UsersRepository repository = UsersRepository();

  List<UserAccount> users = [];

  Future getUsers() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('name', isNotEqualTo: currentUser.displayName)
        .get()
        .then((snapshot) => snapshot.docs.forEach((doc) {
              users.add(UserAccount.fromSnapshot(doc));
            }));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final user = UserAccount.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (user.userid != currentUser.uid) {
        return ListTile(title: Text(user.name));
      }
    }
    return const SizedBox.shrink();
  }

  Widget _noItem() {
    return const Center(child: Text('Non hai ancora amici, aggiungili!'));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!.map((user) => _buildListItem(context, user)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cerca amici"), actions: <Widget>[
        FutureBuilder(
          future: getUsers(),
          builder: (context, snapshot) {
            return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: FriendSearch(users: users));
                });
          },
        ),
      ]),
      body: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _noItem();
            }
            return _buildList(context, snapshot.data?.docs ?? []);
          }),
    );
  }
}

class FriendSearch extends SearchDelegate<String> {
  final List<UserAccount> users;

  FriendSearch({required this.users});

  final recentUsers = [];

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
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var user in users) {
      if (user.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: ((context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = query.isEmpty
        ? recentUsers
        : users.where((element) => element.name.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
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
