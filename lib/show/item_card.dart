import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/widgets/maps.dart';
import 'package:planup/widgets/shopping.dart';
import 'package:planup/widgets/tickets.dart';

import '../widgets/checklist.dart';
import '../widgets/notes.dart';

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
              context.pushNamed('tickets', extra: widget.trav);
              break;
            case 2:
              context.pushNamed('map', extra: widget.trav);
              break;
            case 3:
              context.pushNamed('shopping', extra: widget.trav);
              break;
            case 4:
              context.pushNamed('checklist', extra: widget.trav);
              break;
            case 5:
              context.pushNamed('notes', extra: widget.trav);
              break;

            default:
              context.pushNamed('home');
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
