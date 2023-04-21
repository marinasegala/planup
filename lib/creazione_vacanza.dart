import 'package:flutter/material.dart';

class New extends StatelessWidget{
  const New({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea il tuo viaggio'),
      ),
      body: Center(child: Text('You have pressed the button times.')),
      
    );
  }
}


