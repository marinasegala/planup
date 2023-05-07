import 'package:flutter/material.dart';

class Tickets extends StatefulWidget{
  const Tickets({super.key});

  @override
  State<Tickets> createState() => _TicketState();
}

class _TicketState extends State<Tickets> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I tuoi biglietti'),
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