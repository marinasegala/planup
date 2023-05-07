import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/travel.dart';

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
                border: OutlineInputBorder(), hintText: 'Enter the name'),
              onChanged: (text) => nameTrav = text,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(), hintText: 'Number of participants'),
              onChanged: (text) => part = text,
            ),
          ),
          const Text('Durata del viaggio', ),  
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //const SizedBox(width: 20,),
              ElevatedButton(
                onPressed: () {
                  if (nameTrav != null && part.isNotEmpty) {
                    final newTrav = Travel(nameTrav!, partecipant: part);
                    repository.add(newTrav);
                    //Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data'))
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Annulla'),
              ),
              const SizedBox(height: 20, width: 20,),
              ElevatedButton(
                onPressed: () {
                  if (nameTrav != null && part.isNotEmpty) {
                    final newTrav = Travel(nameTrav!, partecipant: part);
                    repository.add(newTrav);
                    //Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data'))
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Invia'),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 16.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       if (nameTrav != null && part.isNotEmpty) {
          //         final newTrav = Travel(nameTrav!, partecipant: part);
          //         repository.addPet(newTrav);
          //         //Navigator.of(context).pop();
          //         ScaffoldMessenger.of(context).showSnackBar(
          //             const SnackBar(content: Text('Processing Data'))
          //         );
          //         Navigator.pop(context);
          //       }
          //     },
          //     child: const Text('Submit'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
