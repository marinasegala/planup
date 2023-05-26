import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/friends.dart';
import 'package:planup/home_travel.dart';
import 'package:planup/login.dart';
import 'package:planup/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeTravel(),
    ProfilePage(),
    FriendPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return _widgetOptions.elementAt(_selectedIndex);
            } else {
              print(snapshot.connectionState.toString());
              return const LoginPage();
            }
          } else {
            return const Center(
              child: Text("Loading..."),
            );
          }
        },
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
