import 'package:flutter/material.dart';
import 'package:planup/home.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/widgets/checklist.dart';
import 'package:planup/widgets/maps.dart';
import 'package:planup/widgets/notes.dart';
import 'package:planup/widgets/shopping.dart';
import 'package:planup/widgets/tickets.dart';

// ignore: must_be_immutable
class ItemWidget extends StatefulWidget {
  String name = '';
  IconData icon;
  int index;
  Travel trav;

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
            case 1:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => Tickets(trav: widget.trav)));
              break;
            case 2:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => MapsPage(trav: widget.trav)));
              break;
            case 3:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => Shopping(trav: widget.trav)));
              break;
            case 4:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => ItemCheckList(trav: widget.trav)));
              break;
            case 5:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => Notes(trav: widget.trav)));
              break;

            default:
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const HomePage()));
          }
        },
        child: Card(
          color: const Color.fromARGB(255, 231, 242, 239),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.13,
              child: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  Icon(widget.icon),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Text(widget.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )),
        ));
  }
}
