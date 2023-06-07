import 'package:flutter/material.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/travel_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TravCard extends StatelessWidget {
  final Travel trav;
  final TextStyle boldStyle;
  const TravCard({Key? key, required this.trav, required this.boldStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
          title: Text(trav.name, style: boldStyle),
          leading: Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: trav.photo!.isEmpty
                ? ClipOval(
                    child: const Icon(Icons.photo),
                  )
                : ClipOval(
                    child: Image.network(trav.photo!, fit: BoxFit.fitWidth),
                  ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.travSubtitle(trav.numFriend as int),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => TravInfo(trav: trav)));
          }),
    );
  }
}
