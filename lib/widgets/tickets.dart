import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
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
  late String p;
  

  late Future<ListResult> futureFiles;

  @override
  void initState(){
    super.initState();
    futureFiles = FirebaseStorage.instance
      .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}}')
      .listAll();
  }
  
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
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
      p = file.path;
    });
    print('ciao: ${file.path}');
    setState(() {});
    // buildProgress() ;
  }

  Future<ListResult> listFiles() async{
    ListResult list = await FirebaseStorage.instance
      .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}')
      .listAll();
    list.items.forEach((Reference ref) { print('found: $ref');});
    return list;
  }

  Future<String> downloadUrl(String nameImage) async{
    String downloadUrl = await FirebaseStorage.instance
      .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}/${nameImage}')
      .getDownloadURL();

    return downloadUrl;
      
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
                buildProgress(), 
                FutureBuilder(
                  future: listFiles(),
                  builder: (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                      return Container( 
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          // shrinkWrap: true,
                          itemCount: snapshot.data!.items.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                
                                },
                                child: Text(snapshot.data!.items[index].name),
                              ),
                            );
                        })
                      );
                    }
                    if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData){
                      return const CircularProgressIndicator();
                    }
                    return Container();
                  }
                ),

                FutureBuilder(
                  future: downloadUrl('dispensa-fisica.pdf'),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                      return Container(
                        width: 300,
                        height: 250,
                        // child: Image.network(snapshot.data!, fit: BoxFit.cover),
                        child: PdfView(path: p),
                      );
                    }
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const CircularProgressIndicator();
                    }
                    if(!snapshot.hasData) { return const Center(child: Text('Non ci sono biglietti'));}
                    return const SizedBox.shrink();                    
                  }
                ),
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