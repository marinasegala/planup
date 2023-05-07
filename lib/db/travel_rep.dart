import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:planup/model/travel.dart';

class DataRepository {
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
  void updatePet(Travel trav) async {
    await collection.doc(trav.referenceId).update(trav.toJson());
  }
  // 5
  void deletePet(Travel trav) async {
    await collection.doc(trav.referenceId).delete();
  }
}
