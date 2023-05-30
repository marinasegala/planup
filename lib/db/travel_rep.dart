import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:planup/model/travel.dart';

class TravelRepository {

  final CollectionReference collection = FirebaseFirestore.instance.collection('travel');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> add(Travel trav) {
    return collection.add(trav.toJson());
  }

  void updateTravel(Travel trav) async {
    await collection.doc(trav.referenceId).update(trav.toJson());
  }

  void deleteTravel(Travel trav) async {
    await collection.doc(trav.referenceId).delete();
  }

  Future<List<String>> getPartecipants(String id) async {
    List<String> partecipants = [];
    await collection.get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        if (element['referenceId'] == id) {
          partecipants = List.from(element['list part']);
        }
      }
    });
    return partecipants;
  }
}
