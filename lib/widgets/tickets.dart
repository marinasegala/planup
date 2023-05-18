import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Tickets extends StatefulWidget {
  final String trav;
  const Tickets({Key? key, required this.trav}) : super(key: key);

  @override
  State<Tickets> createState() => _TicketState();
}

class _TicketState extends State<Tickets> {
  XFile? image;
  File? file;
  String imageUrl = '';

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
    Reference referenceDirImage = storageReference.child('tickets');

    // create a reference for the image to be stored
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
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
                      getImageFromGallery();
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
                      getImageFromCamera();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I miei biglietti'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: const Center(child: Text('TODO: add widget')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            choosePhoto();
          },
          backgroundColor: const Color.fromARGB(255, 255, 217, 104),
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
