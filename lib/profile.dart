import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Il mio profilo"),
      ),
      body: Align(
          alignment: Alignment.topCenter, //aligns to topCenter
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 10),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  )),
              const Text("Mario", style: TextStyle(fontSize: 30)),
              const Text("mario_rossi", style: TextStyle(fontSize: 20))
            ],
          )),
    );
  }
}
