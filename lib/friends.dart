import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/friends_rep.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/friend_profile.dart';
import 'package:planup/model/friend.dart';
import 'package:planup/model/user_account.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    userRepository.getStream().listen((event) {
      users = event.docs
          .map((e) => UserAccount.fromSnapshot(e))
          .where((element) => element.userid != currentUser.uid)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final friends = Friend.fromSnapshot(snapshot);
    if (FirebaseAuth.instance.currentUser != null) {
      if (friends.userid == currentUser.uid) {
        final user = users.firstWhere(
          (element) => element.userid == friends.userIdFriend,
          orElse: () => UserAccount(' ', ' ', ' ', ' '),
        );
        return ListTile(
            leading: user.photoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl!),
                    radius: 18,
                  )
                : const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // we push the page using the name and we pass the user as extra argument
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => FriendProfile(friend: user)));
                },
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            trailing: TextButton(
                onPressed: () {
                  removeFriend(user.userid!);
                },
                child: Text(AppLocalizations.of(context)!.remove)));
      }
    }
    return const SizedBox.shrink();
  }

  Widget _noItem() {
    return Center(child: Text(AppLocalizations.of(context)!.noFriends));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
      children:
          snapshot!.map((friends) => _buildListItem(context, friends)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.searchFriends),
          actions: <Widget>[
            StreamBuilder(
              stream: userRepository.getStream(),
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
              return Center(child: Text(AppLocalizations.of(context)!.loading));
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
}

class UserSearch extends SearchDelegate<String> {
  final List<UserAccount> users;

  UserSearch({required this.users});

  final recentUsers = [];

  FriendsRepository friendsRepository = FriendsRepository();
  User currentUser = FirebaseAuth.instance.currentUser!;

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
    List<UserAccount> matchQuery = [];
    for (var user in users) {
      if (user.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user);
      }
    }

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          leading: matchQuery[index].photoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(matchQuery[index].photoUrl!),
                  radius: MediaQuery.of(context).size.width * 0.05,
                )
              : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
          title: Text(matchQuery[index].name,
              style: Theme.of(context).textTheme.labelSmall),
          trailing: FutureBuilder(
              future: friendsRepository.isAlreadyFriend(
                  currentUser.uid, matchQuery[index].userid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else {
                  if (snapshot.data == true) {
                    return TextButton(
                      onPressed: () {
                        removeFriend(matchQuery[index].userid!);
                        close(context, '');
                      },
                      child: Text(AppLocalizations.of(context)!.remove),
                    );
                  } else {
                    return TextButton(
                      onPressed: () {
                        addFriend(matchQuery[index].userid!);
                        close(context, '');
                      },
                      child: Text(AppLocalizations.of(context)!.addFriend),
                    );
                  }
                }
              })),
      itemCount: matchQuery.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = query.isEmpty
        ? recentUsers
        : users
            .where((element) =>
                element.userid != currentUser.uid &&
                element.name.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          leading: suggestion[index].photoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(suggestion[index].photoUrl!),
                  radius: MediaQuery.of(context).size.width * 0.05,
                )
              : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
          title: Text(suggestion[index].name,
              style: Theme.of(context).textTheme.labelSmall),
          trailing: FutureBuilder(
              future: friendsRepository.isAlreadyFriend(
                  currentUser.uid, suggestion[index].userid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else {
                  if (snapshot.data == true) {
                    return TextButton(
                      onPressed: () {
                        removeFriend(suggestion[index].userid!);
                        close(context, '');
                      },
                      child: Text(AppLocalizations.of(context)!.remove),
                    );
                  } else {
                    return TextButton(
                      onPressed: () {
                        addFriend(suggestion[index].userid!);
                        close(context, '');
                      },
                      child: Text(AppLocalizations.of(context)!.addFriend),
                    );
                  }
                }
              })),
      itemCount: suggestion.length,
    );
  }
}

Future addFriend(String userIdFriend) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FriendsRepository friendRepository = FriendsRepository();

  return await friendRepository.addFriend(currentUser.uid, userIdFriend);
}

Future removeFriend(String userIdFriend) async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FriendsRepository friendRepository = FriendsRepository();

  friendRepository.deleteFriend(currentUser.uid, userIdFriend);
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
