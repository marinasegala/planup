import 'package:flutter/material.dart';
import 'package:planup/widgets/shopping.dart';
import 'package:planup/widgets/tickets.dart';

class ItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          switch (index) {
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Shopping(trav: trav)),
              );
              break;

            default:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Tickets()),
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
                  Icon(icon),
                  const SizedBox(width: 10),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              )),
        ));
  }
}
