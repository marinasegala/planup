import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/friends.dart';
import 'package:planup/home_travel.dart';
import 'package:planup/model/user_account.dart';
import 'package:planup/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  UsersRepository usersRepository = UsersRepository();
  final currentUser = FirebaseAuth.instance.currentUser;
  UserAccount? user;

  void getUser() {
    usersRepository.getStream().listen((event) {
      for (var user in event.docs) {
        if (user['userid'] == currentUser!.uid) {
          setState(() {
            this.user = UserAccount.fromSnapshot(user);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    print('user: $user');
    final List<Widget> widgetOptions = <Widget>[
      const HomeTravel(),
      ProfilePage(user: user),
      const FriendPage()
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp), label: 'Me'),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervisor_account), label: 'Amici'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
