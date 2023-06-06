import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/friends.dart';
import 'package:planup/home_travel.dart';
import 'package:planup/profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final List<Widget> widgetOptions = <Widget>[
    const HomeTravel(),
    const ProfilePage(),
    const FriendPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle_sharp),
              label: AppLocalizations.of(context)!.myProfile),
          BottomNavigationBarItem(
              icon: const Icon(Icons.supervisor_account),
              label: AppLocalizations.of(context)!.friends),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
