import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/checklist.dart';

class ListRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('check');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Check check) {
    return collection.add(check.toJson());
  }

  // 4
  void updateTravel(Check check) async {
    await collection.doc(check.referenceId).update(check.toJson());
  }

  // 5
  void deleteTravel(Check check) async {
    await collection.doc(check.referenceId).delete();
  }
}
