import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/ticket.dart';

class TicketRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('ticket');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Ticket tick) {
    return collection.add(tick.toJson());
  }

  // 4
  void updateTravel(Ticket tick) async {
    await collection.doc(tick.referenceId).update(tick.toJson());
  }

  // 5
  void deleteTravel(Ticket tick) async {
    await collection.doc(tick.referenceId).delete();
  }
}
