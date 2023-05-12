import 'package:flutter/material.dart';
import 'model/travel.dart';

class Setting extends StatelessWidget {
  final Travel trav;
  const Setting({Key? key, required this.trav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Impostazioni'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: const Center(child: Text('TODO: add widget')),
      ),
    );
  }
}
