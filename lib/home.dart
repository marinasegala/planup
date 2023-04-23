import 'package:flutter/material.dart';
import 'package:planup/create_travel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomePage();
}

class HomePage extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I tuoi viaggi'),
      ),
      body: const Center(child: Text('Press the + button below!')),
      // An example of the floating action button.
      //
      // https://m3.material.io/components/floating-action-button/specs
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //                 content: Text('Text button is pressed')));
          // const New();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTravelPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 217, 104),
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
