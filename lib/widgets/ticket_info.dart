import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/ticket.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../model/travel.dart';

class TicketInfo extends StatefulWidget {
  final Ticket tick;
  final Travel trav;
  final String path;
  const TicketInfo(
      {Key? key, required this.tick, required this.trav, required this.path})
      : super(key: key);

  @override
  State<TicketInfo> createState() => _TicketInfoState();
}

class _TicketInfoState extends State<TicketInfo> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final pdfController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
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
          body: Container(
            child: widget.tick.ext == 'Image'
                ? Image.network(widget.tick.url!)
                : SfPdfViewer.network(widget.tick.url!,
                    scrollDirection: PdfScrollDirection.horizontal),
          ),
        ));
  }
}
