import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/widgets/tickets.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class ItemWidget extends StatelessWidget {
  String name ='';
  IconData icon;
  int index;

  ItemWidget({
    Key? key,
    required this.name,
    required this.icon,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 2:
            
            break;
          
          default: Navigator.push(context, MaterialPageRoute(builder: (context) => const Tickets()),);
        }
      },
      child: Card(
        color: const Color.fromARGB(255, 231, 242, 239),
          child: SizedBox(
            width: 270,
            height: 90,
            child: Row(
              children: [
                const SizedBox(width: 15),
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  name, 
                  style:const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
                ),
              ],
            )
          ),
      ) 
    );
  }
}