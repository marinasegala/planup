import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/friend_profile.dart';
import 'package:planup/model/friend.dart';
import 'package:planup/model/userAccount.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final UsersRepository userRepository = UsersRepository();
  final FriendsRepository friendRepository = FriendsRepository();

  List<UserAccount> users = [];

  void getUsers() {
    UsersRepository().getStream().listen((event) {
      users = event.docs.map((e) => UserAccount.fromSnapshot(e)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final friends = Friend.fromSnapshot(snapshot);
    UserAccount user;
    if (FirebaseAuth.instance.currentUser != null) {
      if (friends.userid == currentUser.uid) {
        // get the friend name from the list of users
        getUsers();
        user = users.firstWhere(
          (element) => element.userid == friends.userIdFriend,
          orElse: () => UserAccount('Not found', 'Not found'),
        );
        return ListTile(
            leading: const Icon(Icons.person),
            title: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  _navigateToFriendPage(user);
                },
                child: Text(
                  user.name,
                ),
              ),
            ),
            trailing:
                TextButton(onPressed: () {}, child: const Text('Rimuovi')));
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
      children:
          snapshot!.map((friends) => _buildListItem(context, friends)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cerca amici"), actions: <Widget>[
        StreamBuilder(
          builder: (context, snapshot) {
            return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: UserSearch(users: users));
                });
          },
        ),
      ]),
      body: StreamBuilder<QuerySnapshot>(
          stream: friendRepository.getStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text('Loading...'));
            } else {
              final hasFriends = _hasFriends(snapshot);
              if (!hasFriends) {
                return _noItem();
              }
            }
            return _buildList(context, snapshot.data!.docs);
          }),
    );
  }

  void _navigateToFriendPage(UserAccount friend) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return FriendProfile(friend: friend);
    }));
  }
}

class UserSearch extends SearchDelegate<String> {
  final List<UserAccount> users;

  UserSearch({required this.users});

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
        : users
            .where((element) => element.name.toLowerCase().startsWith(query))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.person),
          title: Text(suggestion[index].name,
              style: const TextStyle(color: Colors.black, fontSize: 16)),
          trailing: TextButton(
            onPressed: () {
              addFriend(suggestion[index].userid);
            },
            child: const Text('Aggiungi'),
          )),
      itemCount: suggestion.length,
    );
  }
}

Future addFriend(String userIdFriend) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FriendsRepository friendRepository = FriendsRepository();

  return await friendRepository.addFriend(currentUser.uid, userIdFriend);
}

// function to check if the user has friends
bool _hasFriends(AsyncSnapshot<QuerySnapshot> snapshot) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final friends = snapshot.data!.docs;
  for (var friend in friends) {
    if (friend['userid'] == currentUser.uid) {
      return true;
    }
  }
  return false;
}
