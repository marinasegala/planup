import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CreateTravelPage extends StatelessWidget {
  const CreateTravelPage({super.key});

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
              const CreateTravelForm(),
            ],
          )),
    );
  }
}

class CreateTravelForm extends StatefulWidget {
  const CreateTravelForm({super.key});

  @override
  State<CreateTravelForm> createState() => _CreateTravelFormState();
}

class _CreateTravelFormState extends State<CreateTravelForm> {
  final _formKey = GlobalKey<FormState>();

  late DatabaseReference db;
  final nameController = TextEditingController();
  final partController = TextEditingController();

  @override
  void initState(){
    super.initState();
    db = FirebaseDatabase.instance.ref().child('Travel');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: nameController,
              strutStyle: const StrutStyle(
                height: 0.6,
              ),
              decoration: const InputDecoration(
                icon: Icon(Icons.pin_drop_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                labelText: 'Nome del viaggio',
              ),
              // the validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il nome del viaggio';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: partController,
              strutStyle: const StrutStyle(
                height: 0.6,
              ),
              decoration: const InputDecoration(
                icon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                labelText: 'Numero di persone',
              ),
              // the validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il numero di persone';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                Map<String, String> travel = {
                  'name' : nameController.text,
                  'participant' : partController.text,
                };
                db.push().set(travel);
                if (_formKey.currentState!.validate()) {
                  // if the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data'))
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
