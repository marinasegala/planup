
import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planup/model/ticket.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/travel.dart';

class TicketInfo extends StatefulWidget {
  final Ticket tick;
  final Travel trav;
  final String path;
  TicketInfo({Key? key, required this.tick, required this.trav, required this.path}) : super(key: key);

  @override
  State<TicketInfo> createState() => _TicketInfoState();
}

class _TicketInfoState extends State<TicketInfo>{

  final currentUser = FirebaseAuth.instance.currentUser!;
  String pathPdf = '';
  late String doc;

  @override
  void initState(){
    super.initState();
    createFileOfPdfUrl().then((f) {
      pathPdf = f.path;
    });
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final filename = widget.path.substring(widget.path.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(widget.path));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<String> downloadUrl(String nameImage) async {
    String downloadUrl = await FirebaseStorage.instance
        .ref('tickets/${widget.trav.referenceId}/${currentUser.uid}/$nameImage')
        .getDownloadURL();
    // var doc = 
    setState(() {
      doc = downloadUrl;
    });
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context){
     return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tick.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
          }),
        ),
        body: //tick.ext == 'Image' 
         FutureBuilder(
          future: downloadUrl(widget.tick.nameFile as String),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              if(widget.tick.ext == 'Image'){
                return Image.network(snapshot.data!);
              } else {
                print(snapshot.data!);
                // return Text(snapshot.data!);
                return PDFScreen(path: widget.path,);
              }
              
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

class PDFScreen extends StatefulWidget {
  final String? path;

  PDFScreen({Key? key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.red,
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: false,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Go to ${pages! ~/ 2}"),
              onPressed: () async {
                await snapshot.data!.setPage(pages! ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}