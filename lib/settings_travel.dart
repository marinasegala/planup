

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'model/travel.dart';

class SettingTravel extends StatefulWidget {
  final Travel travel;
  const SettingTravel({Key? key, required this.travel}) : super(key: key);

  @override
  State<SettingTravel> createState() => _SettingTravelState();
}

class _SettingTravelState extends State<SettingTravel> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  XFile? image;
  File? file;
  String imageUrl = '';
  String uniqueFileName = '';
  final ImagePicker picker = ImagePicker();

  // void uploadFile() async {
  //   // get a reference to storage root
  //   Reference storageReference = FirebaseStorage.instance.ref();
  //   Reference referenceDirImage = storageReference.child('images');
    
  //   // create a reference for the image to be stored
  //   uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  //   Reference imageReference = referenceDirImage.child(uniqueFileName);

  //   // handle errors/success
  //   try {
  //     // store the image
  //     await imageReference.putFile(File(image!.path));
  //     imageReference.
  //     // await imageReference.putFile(File(image!.path));

  //     // success: get the download url
  //     imageUrl = await imageReference.getDownloadURL();

  //     // update the UI
  //     setState(() {});
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    String updateName = widget.travel.name;
    String updatePart = widget.travel.partecipant;
    String? updateDate = widget.travel.date;
    bool canupdateDate = false;
    var id = widget.travel.referenceId;
    final isimageRef = FirebaseStorage.instance.ref().child("images").child('${widget.travel.photo}').getDownloadURL() ;
    

    print('ref $isimageRef');
    void choosePhoto() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: const Text('Seleziona il metodo di caricamento'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 6,
                child: Column(
                  children: [
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        Navigator.pop(context);
                        // getImageFromGallery();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.image),
                          Text('Galleria'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      //if user click this button. user can upload image from camera
                      onPressed: () {
                        Navigator.pop(context);
                        // getImageFromCamera();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.camera),
                          Text('Camera'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context, true), // passing true
                  icon: const Icon(Icons.clear),
                ),
              ],
            );
          });
    }
    
    Future<void> updateItem( String field, String newField) {
      return FirebaseFirestore.instance
          .collection('travel')
          .doc(id)
          .update({field: newField}).then(
              (value) => {
                print("Update"),
              },
              onError: (e) => print("Error updating doc: $e"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: widget.travel.photo != ''
                    ? const ClipOval(
                        child: Icon(
                          Icons.add,
                          size: 50,
                        ),
                      )
                    : const ClipOval(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                        ),
                      )
          ),
            ElevatedButton(
              onPressed: () {
                choosePhoto();
                // reload the page
              },
              child: const Text('Cambia Foto'),
            ),
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
                hintText:
                    'Numero dei partecipanti: ${widget.travel.partecipant}',
                counterText: 'Scrivi per modificare il numero',
              ),
              onChanged: (text) => updatePart = text,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
                      '\nSe non si conoscono ancora scrivere una delle seguenti scelte: \n\n                   Giornata \n                   Weekend \n                  Settimana \n                      Altro',
                      textAlign: TextAlign.justify,
                    ),
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
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                if (updateDate != null && updateDate!.isNotEmpty) {
                  if (updateDate?.toLowerCase() == 'giornata' ||
                      updateDate?.toLowerCase() == 'settimana' ||
                      updateDate?.toLowerCase() == 'weekend' ||
                      updateDate?.toLowerCase() == 'altro') {
                    canupdateDate = true;
                  }
                  if (updateDate?.length == 24 || updateDate?.length == 10) {
                    canupdateDate = true;
                  }
                }
                
                FirebaseFirestore.instance
                  .collection('travel')
                  .doc(id)
                  .get().then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      if (updateName != widget.travel.name) {
                        updateItem('name', updateName);
                      }
                      if (updatePart != widget.travel.partecipant) {
                        updateItem('partecipant', updatePart);
                      }
                      if (canupdateDate) {
                        if (updateDate != widget.travel.date) {
                          FirebaseFirestore.instance
                              .collection('travel')
                              .doc(id)
                              .update({'exactly date': updateDate}).then(
                                  (value) => {print("Update")},
                                  onError: (e) =>
                                      print("Error updating doc: $e"));
                        }
                      }
                    }
                });
                // check
                ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')));
                    // : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //     content: Text(
                    //         'Qualcosa è andato storto! Riguarda ciò che hai scritto')));
              },
              child: const Text(
                'Invia',
                style: TextStyle(fontSize: 16),
              )),
        ],
      ),
    );
  }
}
