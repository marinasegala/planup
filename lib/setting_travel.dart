import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'model/travel.dart';

class Setting extends StatelessWidget {
  final Travel trav;
  const Setting({Key? key, required this.trav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String updateName = trav.name;
    String updatePart = trav.partecipant;
    String? updateDate = trav.date;

    Future<void> updateTravel(String id, String field, String newField) async {
      return FirebaseFirestore.instance
          .collection("travel")
          .doc(id)
          .update({field: newField})
          .then(
            (value) => print("DocumentSnapshot successfully updated!"),
            onError: (e) => print("Error updating document $e")
          );
    }
    
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.group_outlined),
                      hintText: 'Numero di partecipanti:  ${trav.partecipant}'),
                  onChanged: (text) => updatePart = text,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        if(updateName != trav.name){
                          print("${trav.date} - ${trav.name}");
                          var query = FirebaseFirestore.instance
                            .collection('travel')
                            .where("name", isEqualTo: trav.name)
                            .where('partecipant', isEqualTo: trav.partecipant)
                            // .where("exaclty date", isEqualTo: trav.date)
                            .get()
                            .then( (querySnapshot) {
                              
                              for (var docSnapshot in querySnapshot.docs) {
                                
                                print('c: ${docSnapshot.id} => ${docSnapshot.data()}');
                                updateTravel(docSnapshot.id, 'name', updateName);
                              }
                            },);
                            
                        }
                        if(updatePart != trav.partecipant){
                          FirebaseFirestore.instance
                            .collection('travel')
                            .where("participant", isEqualTo: trav.partecipant)
                            .get()
                            .then( (querySnapshot) {
                              for (var docSnapshot in querySnapshot.docs) {
                                // print('${docSnapshot.id} => ${docSnapshot.data()}');
                                updateTravel(docSnapshot.id, 'name', updateName);
                              }
                            },);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Invia', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
