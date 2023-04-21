import 'package:flutter/material.dart';

class New extends StatelessWidget{
  const New({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea il tuo viaggio'),
      ),
      body: Align(
          alignment: Alignment.topCenter,//aligns to topCenter
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                )
              ),
              
          ],) 
        ),
    );
  }
}


