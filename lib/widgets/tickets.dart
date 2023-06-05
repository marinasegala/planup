import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crea_radio_button/crea_radio_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/ticket_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:planup/widgets/ticket_info.dart';

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
  late String p = '';
  String name = '';

  String changeExt = '';
  String ext = '';

  late Future<ListResult> futureFiles;

  @override
  void initState() {
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

  Future uploadFile() async {
    final path =
        'tickets/${widget.trav.referenceId}/${currentUser.uid}/${pickedfile!.name}';
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

    var newTicket = Ticket(
      name,
      nameFile: pickedfile!.name,
      trav: widget.trav.referenceId,
      userid: currentUser.uid,
      url: urlDownload,
      ext: ext,
    );
    repository.add(newTicket);

    setState(() {});
    // buildProgress() ;
  }

  Future<ListResult> listFiles() async {
    ListResult list = await FirebaseStorage.instance
        .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}')
        .listAll();
    list.items.forEach((Reference ref) {
      print('found: $ref');
    });
    return list;
  }

  Future<String> downloadUrl(String nameImage) async {
    String downloadUrl = await FirebaseStorage.instance
        .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}/$nameImage')
        .getDownloadURL();

    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
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
                        AppLocalizations.of(context)!.uploadProgress(
                            (100 * progress).roundToDouble().toString()),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ));
          } else {
            return const SizedBox.shrink();
          }
        });

    List<RadioOption> options = [
      RadioOption("pdf", AppLocalizations.of(context)!.extPdf),
      RadioOption("image", AppLocalizations.of(context)!.extImage),
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myTickets),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        // body: Padding(
        //   padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        //   child: Column(
        //       mainAxisAlignment: MainAxisAlignment.start,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         buildProgress(),
        //         FutureBuilder(
        //             future: listFiles(),
        //             builder: (BuildContext context,
        //                 AsyncSnapshot<ListResult> snapshot) {
        //               if (snapshot.connectionState == ConnectionState.done &&
        //                   snapshot.hasData) {
        //                 return Container(
        //                     padding: const EdgeInsets.symmetric(vertical: 20),
        //                     height: 300,
        //                     child: ListView.builder(
        //                         scrollDirection: Axis.vertical,
        //                         itemCount: snapshot.data!.items.length,
        //                         itemBuilder: (context, index) {
        //                           return Padding(
        //                             padding: const EdgeInsets.all(8.0),
        //                             child: ElevatedButton(
        //                               onPressed: () {},
        //                               child: Text(
        //                                   snapshot.data!.items[index].name),
        //                             ),
        //                           );
        //                         }));
        //               }
        //               if (snapshot.connectionState == ConnectionState.waiting ||
        //                   !snapshot.hasData) {
        //                 return const CircularProgressIndicator();
        //               }
        //               return Container();
        //             }),
        //         FutureBuilder(
        //             future: downloadUrl('dispensa-fisica.pdf'),
        //             builder:
        //                 (BuildContext context, AsyncSnapshot<String> snapshot) {
        //               if (snapshot.connectionState == ConnectionState.done &&
        //                   snapshot.hasData) {
        //                 return Container(
        //                   width: 300,
        //                   height: 250,
        //                   child: PdfView(path: p),
        //                 );
        //               }
        //               if (snapshot.connectionState == ConnectionState.waiting) {
        //                 return const CircularProgressIndicator();
        //               }
        //               if (!snapshot.hasData) {
        //                 return Center(
        //                     child:
        //                         Text(AppLocalizations.of(context)!.noTickets));
        //               }
        //               return const SizedBox.shrink();
        //             }),
        //       ]),
        // ),
        body: StreamBuilder<QuerySnapshot>(
            stream: repository.getStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: Text(AppLocalizations.of(context)!.loading));
              } else {
                final hasMyOwnTravel =
                    _hasMyOwnData(snapshot, widget.trav.referenceId as String);
                if (!hasMyOwnTravel) {
                  return _noItem();
                } else {
                  return _buildList(context, snapshot.data!.docs, snapshot);
                }
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(AppLocalizations.of(context)!.addTicket),
                    content: Column(children: [
                      TextFormField(
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.nameTicket),
                        onChanged: (text) => name = text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                      ),
                      RadioButtonGroup(
                          options: options,
                          preSelectedIdx: 0,
                          vertical: true,
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          selectedColor:
                              const Color.fromARGB(255, 195, 190, 190),
                          mainColor: const Color.fromARGB(255, 195, 190, 190),
                          selectedBorderSide: const BorderSide(
                              width: 2,
                              color: Color.fromARGB(255, 64, 137, 168)),
                          buttonWidth: 105,
                          buttonHeight: 35,
                          callback: (RadioOption val) {
                            setState(() {
                              changeExt = val.label;
                              ext = changeExt;
                            });
                          }),
                    ]),
                    actions: [
                      ElevatedButton(
                        onPressed: selectFile,
                        child: Text(AppLocalizations.of(context)!.uploadTicket),
                      ),
                      // const SizedBox(width: 10,),
                      // ElevatedButton(
                      //   onPressed: () => Navigator.pop(context),
                      //   child: Text(AppLocalizations.of(context)!.close),
                      // )
                    ],
                  );
                });
          },
          backgroundColor: const Color.fromARGB(255, 255, 217, 104),
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ));
  }

  Widget _noItem() {
    return Center(
        child: Text(
      AppLocalizations.of(context)!.noTickets,
      style: const TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    ));
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot,
      AsyncSnapshot<QuerySnapshot> querysnapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10.0),
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final tick = Ticket.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (tick.userid == currentUser.uid &&
          tick.trav == widget.trav.referenceId) {
        // return Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: ElevatedButton(
        //     onPressed: () {},
        //     child: Text(tick.name),
        //   ),
        // );
        return Card(
            elevation: 2,
            child: InkWell(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 11.0, horizontal: 16.0),
                        child: Center(
                            child: Text(tick.name,
                                style: const TextStyle(fontSize: 18.0))),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              TicketInfo(tick: tick, trav: widget.trav, path: p,)));
                }));
      }
    }
    return const SizedBox.shrink();
  }
}

bool _hasMyOwnData(AsyncSnapshot<QuerySnapshot> snapshot, String id) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final tick = snapshot.data!.docs;
  for (var i = 0; i < tick.length; i++) {
    if (tick[i]['userid'] == currentUser.uid && tick[i]['trav'] == id) {
      return true;
    }
  }
  return false;
}
