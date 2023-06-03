
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:planup/model/ticket.dart';

import '../model/travel.dart';

class TicketInfo extends StatelessWidget {
  final Ticket tick;
  final Travel trav;
  TicketInfo({Key? key, required this.tick, required this.trav}) : super(key: key);

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<String> downloadUrl(String nameImage) async {
    String downloadUrl = await FirebaseStorage.instance
        .ref('tickets/${trav.referenceId}/${currentUser.uid}/$nameImage')
        .getDownloadURL();
    // var doc = 
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context){
     return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tick.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
          }),
        ),
        body: //tick.ext == 'Image' 
         FutureBuilder(
          future: downloadUrl(tick.nameFile as String),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Image.network(snapshot.data!);
                  // : PdfView(path: tick.referenceId as String),
              // );+
              
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return const SizedBox.shrink();
          })
        
      )
    );
  }
}