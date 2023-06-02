import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planup/db/ticket_rep.dart';
import 'package:planup/model/travel.dart';

import '../model/ticket.dart';

class Tickets extends StatefulWidget {
  final Travel trav;
  const Tickets({Key? key, required this.trav}) : super(key: key);

  @override
  State<Tickets> createState() => _TicketState();
}

class _TicketState extends State<Tickets> {

  String uniqueFileName = '';
  String fileURL = '';
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TicketRepository repository = TicketRepository();

  PlatformFile? pickedfile;
  UploadTask? uploadTask;
  String urlDownload = '';
  FilePickerResult? result;
  late File file;
  
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedfile = result.files.first;
    });
    print(pickedfile!.path!);
    uploadFile();
    
  }

  Future uploadFile() async{

    final path = 'tickets/${widget.trav.referenceId}/${currentUser.uid}/${pickedfile!.name}';
    final file = File(pickedfile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    // ref.putFile(file);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      uploadTask = null;
    });
    setState(() {});
    // buildProgress() ;
  }

  
  @override
  Widget build(BuildContext context) {
    Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot){
        if (snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred/data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.teal,
                ),
                Center(
                  child: Text(
                    '${(100*progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          );
        } else { return const SizedBox.shrink();}
      }
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('I miei biglietti'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               buildProgress() 
                
              ]
            ),
          ),
        floatingActionButton: FloatingActionButton(
        onPressed: selectFile,
        backgroundColor: const Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
    ));

    
  }
  
  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot){
        if (snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred/data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.teal,
                ),
                Center(
                  child: Text(
                    '${(100*progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          );
        } else { return const SizedBox.shrink();}
      }
    );
}