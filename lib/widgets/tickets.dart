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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  PlatformFile? pickedfile;
  UploadTask? uploadTask;
  String urlDownload = '';
  FilePickerResult? result;
  late File file;
  late String p = '';
  String name = '';

  String changeExt = '';
  String ext = 'Pdf';

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
  }

  Future<ListResult> listFiles() async {
    ListResult list = await FirebaseStorage.instance
        .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}')
        .listAll();
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
                height: MediaQuery.of(context).size.height * 0.1,
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
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.nameTicket,
                                  border: const OutlineInputBorder()),
                              onChanged: (text) => name = text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .requiredField;
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            RadioButtonGroup(
                                options: options,
                                preSelectedIdx: 0,
                                textStyle: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                selectedColor:
                                    const Color.fromARGB(255, 195, 190, 190),
                                mainColor:
                                    const Color.fromARGB(255, 195, 190, 190),
                                selectedBorderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 64, 137, 168)),
                                buttonWidth:
                                    MediaQuery.of(context).size.width * 0.27,
                                buttonHeight:
                                    MediaQuery.of(context).size.height * 0.05,
                                callback: (RadioOption val) {
                                  setState(() {
                                    changeExt = val.label;
                                    ext = changeExt;
                                  });
                                }),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  selectFile()
                                      .then((value) => Navigator.pop(context));
                                }
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.uploadTicket),
                            ),
                          ],
                        ),
                      ),
                    ]),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  Future<void> deleteItem(String id) {
      return FirebaseFirestore.instance
          .collection("ticket")
          .doc(id)
          .delete()
          .then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );
    }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final tick = Ticket.fromSnapshot(snapshot);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (tick.userid == currentUser.uid &&
          tick.trav == widget.trav.referenceId) {
        return Card(
            elevation: 2,
            child: InkWell(
                child: ListTile(
                    title: Text(
                      tick.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_outlined),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text(AppLocalizations.of(context)!.sureToDeleteTicket),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'No'),
                                  child: Text(AppLocalizations.of(context)!.no, style: TextStyle(fontSize: 16),),
                                ),
                                TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('ticket')
                                        .where("name", isEqualTo: tick.name)
                                        .get()
                                        .then(
                                      (querySnapshot) {
                                        for (var docSnapshot in querySnapshot.docs) {
                                          deleteItem(docSnapshot.id);
                                        }
                                      },
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(fontSize: 16),),
                                ),
                              ],
                            );
                          });
                        
                      },
                    ),
                  ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => TicketInfo(
                                tick: tick,
                                trav: widget.trav,
                                path: p,
                              )));
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
