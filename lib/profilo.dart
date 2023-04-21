import 'package:flutter/material.dart';


class Profilo extends StatelessWidget{
  const Profilo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
          alignment: Alignment.topCenter,//aligns to topCenter
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 10),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                )
              ),
              const Text("Mario", style: TextStyle(fontSize: 30)),
              const Text("mario_rossi", style: TextStyle(fontSize: 20))
          ],) 
        ),
      );
  }
}