import 'package:flutter/material.dart';

class Home extends StatelessWidget{
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FabExample(),
    );
  }
}


class FabExample extends StatelessWidget {
  const FabExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I TUOI VIAGGI'),
      ),
      body: const Center(child: Text('Press the button below!')),
      // An example of the floating action button.
      //
      // https://m3.material.io/components/floating-action-button/specs
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
      ),
    );
  }
}
