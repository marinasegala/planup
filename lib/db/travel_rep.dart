import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:planup/model/travel.dart';

class TravelRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('travel');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Travel trav) {
    return collection.add(trav.toJson());
  }

  // 4
  void updateTravel(Travel trav) async {
    await collection.doc(trav.referenceId).update(trav.toJson());
  }

  // 5
  void deleteTravel(Travel trav) async {
    await collection.doc(trav.referenceId).delete();
  }
}
