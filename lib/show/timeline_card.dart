import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../travel_info.dart';

// ignore: must_be_immutable
class TravelTimeline extends StatefulWidget {
  List<Travel> pastTravels;
  final bool visibility;
  TravelTimeline({super.key, required this.pastTravels, required this.visibility});

  @override
  State<StatefulWidget> createState() => _TravelTimelineState();
}

class _TravelTimelineState extends State<TravelTimeline> {
  TravelRepository travelRepository = TravelRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  void sortListTravel() {
    // sort the list of travels by date
    widget.pastTravels.sort((a, b) => a.date!.compareTo(b.date!));
    // and then reverse it
    widget.pastTravels = widget.pastTravels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    sortListTravel();
    return widget.pastTravels.isEmpty
        ? Center(
            child: Text(
              AppLocalizations.of(context)!.noTravelFriend,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          )
        : Timeline.builder(
            itemBuilder: (BuildContext context, int index) {
              return TimelineModel(
                  TimelineCard(travel: widget.pastTravels[index], vis: widget.visibility),
                  icon: const Icon(Icons.flight),
                  iconBackground: Colors.amber[200]!);
            },
            itemCount: widget.pastTravels.length,
            physics: const ClampingScrollPhysics(),
            position: TimelinePosition.Left,
            lineWidth: 2.0,
          );
  }
}

class TimelineCard extends StatelessWidget {
  final Travel travel;
  final bool vis;
  const TimelineCard({super.key, required this.travel, required this.vis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(travel.name, style: const TextStyle(fontSize: 16)),
        subtitle:
            Text(travel.date as String, style: const TextStyle(fontSize: 12)),
        trailing: travel.photo!.isEmpty
            ? Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.photo),
              )
            : Image.network(travel.photo!),
        onTap: () {
          vis
          ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                content: Text(AppLocalizations.of(context)!.visualize(travel.name)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'No'),
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => TravInfo(trav: travel, isPast: true)));
                    },
                    child: Text(AppLocalizations.of(context)!.yes),
                  ),
                ],
              );
            })
          // : showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return AlertDialog(
          //       scrollable: true,
          //       content: Text(AppLocalizations.of(context)!.visualizeonly),
          //       actions: [
          //         TextButton(
          //           onPressed: () => Navigator.pop(context),
          //           child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontSize: 17),),
          //         ),
          //       ],
          //     );
          //   });
          : null;
        },
      ),
    );
  }
}
