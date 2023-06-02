import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planup/db/authentication_service.dart';
import 'package:planup/login.dart';
import 'package:planup/model/user_account.dart';

import 'home.dart';

class SettingsProfile extends StatefulWidget {
  UserAccount user;
  SettingsProfile({super.key, required this.user});
  @override
  State<SettingsProfile> createState() => _SettingsProfile();
}

class _SettingsProfile extends State<SettingsProfile>{
  final _formKey = GlobalKey<FormState>();
  XFile? image;
  File? file;
  String imageUrl = '';
  String uniqueFileName = '';
  final ImagePicker picker = ImagePicker();
  
  Future getImageFromGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    uploadFile();
  }

  Future<void> getImageFromCamera() async {
    image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    uploadFile();
  }

  void uploadFile() async {
    // get a reference to storage root
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference referenceDirImage = storageReference.child('images');

    // create a reference for the image to be stored
    uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference imageReference = referenceDirImage.child(uniqueFileName);

    // handle errors/success
    try {
      // store the image
      await imageReference.putFile(File(image!.path));

      // success: get the download url
      imageUrl = await imageReference.getDownloadURL();

      // update the UI
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void choosePhoto() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Future<void> updateItem(String field, String newField) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.userid)
        .update({field: newField}).then((value) => print("Update"),
            onError: (e) => print("Error updating doc: $e"));
  }

  @override
  Widget build(BuildContext context) {
    String updateName = widget.user.name;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        actions: [IconButton(
          onPressed: (){
            showDialog(
              context: context, 
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text('Sei sicuro di voler uscire?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'No'), 
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        AuthenticationServices().signOut();
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (builder) => const LoginPage())
                        );
                      }, 
                      child: const Text('Si'),
                    ),
                  ],
                );
              }
            );
          }, 
          icon: const Icon(Icons.logout_outlined, size: 30,)
        )],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          widget.user.photoUrl != null
              ? ClipOval(
                  child: Material(
                    child: Image.network(
                      widget.user.photoUrl as String,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )
              : const ClipOval(
                  child: Material(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.person,
                        size: 60,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => choosePhoto(),
            child: const Text('Cambia Foto'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                icon: const Icon(Icons.person),
                hintText: 'Nome: ${widget.user.name}',
                counterText: 'Scrivi per modificare il nome',
              ),
              onChanged: (text) => updateName = text,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('users')
                .where('userid', isEqualTo: widget.user.userid)
                .get()
                .then((querySnapshot) {
                  for (var docSnapshot in querySnapshot.docs) {
                    // if(updateName != widget.user.name){
                    //   print('cioa $updateName');
                    //   updateItem('name', updateName);
                    // }
                    print(docSnapshot.data());
                    print(updateName );
                    print(widget.user.name );
                  }
              });
              // check
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')));
              setState(() {});
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const HomePage()));
            },
            child: const Text(
              'Invia',
              style: TextStyle(fontSize: 16),
            )),
      ]),
    );

  //       child: widget.user!.photoUrl!.isNotEmpty
  //             ? ClipOval(
  //                 child: Material(
  //                   child: Image.network(
  //                     widget.user!.photoUrl!,
  //                     fit: BoxFit.fitHeight,
  //                   ),
  //                 ),
  //               )
  //             : widget.user!.photoUrl! != imageUrl && image!=null
  //               ? ClipOval(
  //                   child: Material(
  //                     child: Image.file(
  //                       File(image!.path),
  //                       fit: BoxFit.cover,
  //                       width: 100,
  //                       height: 100,
  //                     ),
  //                   )
  //                 )
  //         ElevatedButton(
  //           onPressed: () {
  //             choosePhoto();
  //             // reload the page
  //           },
  //           child: const Text('Cambia Foto'),
  //         ),
  //         const SizedBox(height: 10,),
          // Padding(
          //   padding: const EdgeInsets.all(8),
          //   child: TextField(
          //     autofocus: false,
          //     decoration: InputDecoration(
          //       icon: const Icon(Icons.pin_drop_outlined),
          //       hintText: 'Nome: ${widget.user!.name}',
          //       counterText: 'Scrivi per modificare il nome',
          //     ),
          //     onChanged: (text) => updateName = text,
          //   ),
          // ),
  //         const SizedBox(height: 10,),
  //         ElevatedButton(
  //           onPressed: () {
  //             FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(widget.user!.userid)
  //                 .get()
  //                 .then((DocumentSnapshot documentSnapshot) {
  //               if (documentSnapshot.exists) {
  //                 if (updateName != widget.user!.name) {
  //                   updateItem('name', updateName);
  //                 }
  //               }
  //             });
  //             // check
  //             ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Processing Data')));
  //             setState(() {});
  //             Navigator.pop(context);
  //           },
  //           child: const Text(
  //             'Invia',
  //             style: TextStyle(fontSize: 16),
  //           )
  //         ),
  //     ]),
  //   );
  }
}
