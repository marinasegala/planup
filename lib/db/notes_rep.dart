import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/notes.dart';

class NoteRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('note');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Note note) {
    return collection.add(note.toJson());
  }

  // 4
  void updateTravel(Note note) async {
    await collection.doc(note.referenceId).update(note.toJson());
  }

  // 5
  void deleteTravel(Note note) async {
    await collection.doc(note.referenceId).delete();
  }
}
