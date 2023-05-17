import 'package:flutter/material.dart';
import 'package:planup/maps.dart';
import 'package:planup/widgets/shopping.dart';
import 'package:planup/widgets/tickets.dart';

import '../widgets/notes.dart';

class ItemWidget extends StatefulWidget {
  String name = '';
  IconData icon;
  int index;
  String trav = '';

  ItemWidget({
    Key? key,
    required this.name,
    required this.icon,
    required this.index,
    required this.trav,
  }) : super(key: key);

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          switch (widget.index) {
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MapsPage()));
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Shopping(trav: widget.trav)),
              );
              break;

            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Notes(trav: widget.trav)),
              );
              break;

            default:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Tickets(trav: widget.trav)),
              );
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
                  Icon(widget.icon),
                  const SizedBox(width: 10),
                  Text(widget.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )),
        ));
  }
}
