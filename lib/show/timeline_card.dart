import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class TravelTimeline extends StatelessWidget {
  TravelTimeline({super.key, required this.pastTravels});

  List<Travel> pastTravels;

  TravelRepository travelRepository = TravelRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  void sortListTravel() {
    // sort the list of travels by date
    pastTravels.sort((a, b) => a.date!.compareTo(b.date!));
    // and then reverse it
    pastTravels = pastTravels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    sortListTravel();
    return pastTravels.isEmpty
        ? const Center(
            child: Text(
              "Questo utente non ha ancora viaggiato\nDirei che è il momento di organizzarne uno insieme!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          )
        : Timeline.builder(
            itemBuilder: (BuildContext context, int index) {
              return TimelineModel(TimelineCard(travel: pastTravels[index]),
                  icon: const Icon(Icons.flight),
                  iconBackground: Colors.amber[200]!);
            },
            itemCount: pastTravels.length,
            physics: const ClampingScrollPhysics(),
            position: TimelinePosition.Left,
            lineWidth: 2.0,
          );
  }
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({super.key, required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(travel.name, style: const TextStyle(fontSize: 16)),
        subtitle:
            Text(travel.date as String, style: const TextStyle(fontSize: 12)),
        trailing: travel.photo!.isEmpty
            ? Container(
                padding: const EdgeInsets.all(5),
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
      ),
    );
  }
}
