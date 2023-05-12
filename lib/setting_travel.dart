import 'package:flutter/material.dart';
import 'model/travel.dart';

class Setting extends StatelessWidget {
  final Travel trav;
  const Setting({Key? key, required this.trav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String updateName;
    String updatePart;
    
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Impostazioni'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            
          ),
          
          //body: const Center(child: Text('TODO: add widget')),
          body: Column(
            children: [
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.pin_drop_outlined),
                      hintText: 'Nome del viaggio:  ${trav.name}'),
                  onChanged: (text) => updateName = text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.group_outlined),
                      hintText: 'Numero di partecipanti:  ${trav.partecipant}'),
                  onChanged: (text) => updateName = text,
                ),
              ),
            ],
          ),
        ),
        body: const Center(child: Text('TODO: add widget')),
      ),
    );
  }
}
