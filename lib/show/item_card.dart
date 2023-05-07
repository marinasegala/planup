import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planup/model/travel.dart';

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

  ItemWidget({
    Key? key,
    required this.name,
    //required this.index,
  }) : super(key: key);
  
  
  //String get name => this.name;
  //const ItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    const color = Color.fromARGB(255, 231, 242, 239); //_lightColors[index % _lightColors.length];
    //final time = DateFormat.yMMMd().format(note.createdTime);
    //final minHeight = getMinHeight(index);

    return Card(
      color: color,
      child: Container(
        constraints: const BoxConstraints(minHeight: 55, minWidth: 350),
        padding: const EdgeInsets.all(8),
        //child: Column(
          //mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.start,
        child: //  children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          //],
        ),
      
    );
  }
}