import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'db/shopping_rep.dart';
import 'model/travel.dart';

class SettingTravel extends StatefulWidget {
  final Travel travel;
  const SettingTravel({Key? key, required this.travel}) : super(key: key);

  @override
  State<SettingTravel> createState() => _SettingTravelState();
}


class _SettingTravelState extends State<SettingTravel> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String updateName = widget.travel.name;
    String updatePart = widget.travel.partecipant;
    String? updateDate = widget.travel.date;
    bool _canupdateDate = false;
    bool check = false;

    Future<void> updateItem(String id, String field, String newField){
      return FirebaseFirestore.instance.collection('travel')
        .doc(id)
        .update({field: newField})
        .then((value) => {print("Update"), check = true},
          onError: (e) => print("Error updating doc: $e"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        leading: IconButton(
          onPressed: () { Navigator.pop(context); },
          icon: const Icon(Icons.arrow_back)
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  icon: const Icon(Icons.pin_drop_outlined),
                  hintText: 'Nome del viaggio: ${widget.travel.name}',
                  counterText: 'Scrivi per modificare il nome',
                ),
                onChanged: (text) => updateName = text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  icon: const Icon(Icons.group_outlined),
                  hintText: 'Numero dei partecipanti: ${widget.travel.partecipant}',
                  counterText: 'Scrivi per modificare il numero',
                ),
                onChanged: (text) => updatePart = text,
              ),
            ),
            const SizedBox(height: 10,),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Cambio data'),
                    content: const Text(
                      'Se si sanno le date del viaggio inserire una delle due opzioni: '
                      '\n\n       yyyy-mm-dd to yyyy-mm-dd  \n                  yyyy-mm-dd \n '
                      '\nSe non si conoscono ancora scrivere una delle seguenti scelte: \n\n                   Giornata \n                   Weekend \n                  Settimana \n                      Altro'
                    , textAlign: TextAlign.justify,),
                  
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Hint per cambiare la data'),
            )),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                    icon: const Icon(Icons.date_range_outlined),
                    hintText: 'Date: ${widget.travel.date}'),
                onChanged: (text) => updateDate = text,
              ),
            ),
            
            
            
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                if (updateDate != null && updateDate!.isNotEmpty){
                  if (updateDate?.toLowerCase() == 'giornata' || updateDate?.toLowerCase() == 'settimana' || updateDate?.toLowerCase() == 'weekend' || updateDate?.toLowerCase() == 'altro') {
                    _canupdateDate = true;
                  }
                  if(updateDate?.length == 24 || updateDate?.length == 10){
                    _canupdateDate = true;
                  } 
                }
                FirebaseFirestore.instance.collection('travel')
                    .where('name', isEqualTo: widget.travel.name)
                    .where('partecipant', isEqualTo: widget.travel.partecipant)
                    .get()
                    .then( (querySnapshot) {
                      for (var docSnapshot in querySnapshot.docs){
                        if(updateName != widget.travel.name){
                          updateItem(docSnapshot.id, 'name', updateName);
                        }
                        if(updatePart != widget.travel.partecipant){
                          updateItem(docSnapshot.id, 'partecipant', updatePart);
                        }
                        if(_canupdateDate){
                          if(updateDate != widget.travel.date){
                            
                            FirebaseFirestore.instance.collection('travel')
                              .doc(docSnapshot.id)
                              .update({'exactly date': updateDate})
                              .then((value) => {print("Update"), check = true},
                                onError: (e) => print("Error updating doc: $e"));
                          }
                        }
                      }
                    });
                  check
                  ? ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')))
                  : ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Qualcosa è andato storto! Riguarda ciò che hai scritto')));
                
              }, 
              child: const Text('Invia', style: TextStyle(fontSize: 16),)
            ),
          ],
        ),
      ),
    );
  }

}


