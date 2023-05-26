import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:planup/model/travel.dart';
import 'package:planup/travel_info.dart';

class TravCard extends StatelessWidget {
  final Travel trav;
  final TextStyle boldStyle;
  const TravCard({Key? key, required this.trav, required this.boldStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: InkWell(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 11.0, horizontal: 16.0),
                    child: Text(trav.name, style: boldStyle),
                  ),
                ),
              ],
            ),
            onTap: () => context.pushNamed('home_travel', extra: trav)));
  }
}
