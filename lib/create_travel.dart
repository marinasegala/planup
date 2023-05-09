import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/travel.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'db/travel_rep.dart';

class CreateTravelPage extends StatelessWidget {
  CreateTravelPage({super.key});
  
  final DataRepository repository = DataRepository();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea il tuo viaggio'),
      ),
      body: Align(
          alignment: Alignment.topCenter, //aligns to topCenter
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  )),
              CreateTravelForm(),
            ],
          )),
    );
  }
}

class CreateTravelForm extends StatefulWidget {
  CreateTravelForm({Key? key}) : super(key: key);

  @override
  State<CreateTravelForm> createState() => _CreateTravelFormState();
}

class _CreateTravelFormState extends State<CreateTravelForm> {
  final _formKey = GlobalKey<FormState>();

  String? nameTrav;
  String part = '';
  final DataRepository repository = DataRepository();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.pin_drop_outlined),
                border: OutlineInputBorder(), hintText: 'Inserire il nome del viaggio'),
              onChanged: (text) => nameTrav = text,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(), hintText: 'Numero di partecipanti'),
              onChanged: (text) => part = text,
            ),
          ),
          Column(children: [ 
            Row(
              children: const [
                SizedBox(width: 10, height: 40,),
                Text('Durata del viaggio', style: TextStyle(fontSize: 17),),
              ],
            ),
            const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('So già le date del mio viaggio'),
                SwitchExample(),
              ],
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(width: 20,),              
              const SizedBox(height: 20, width: 20,),
              ElevatedButton(
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser != null) {
                    if (nameTrav != null && part.isNotEmpty) {
                      final newTrav = Travel(nameTrav!, partecipant: part, userid: FirebaseAuth.instance.currentUser?.uid);
                      repository.add(newTrav);
                      //Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data'))
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Invia'),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: const Color.fromARGB(255, 43, 129, 168),
      value: light,
      onChanged: (_value) {
        setState(() {
          light = _value;
        });
      },
    );
  }
}