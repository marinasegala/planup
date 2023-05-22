import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/places.dart';

class PlacesRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('places');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> add(Place place) {
    return collection.add(place.toJson());
  }

  void updatePlace(Place place) async {
    await collection.doc(place.referenceId).update(place.toJson());
  }

  void deletePlace(Place place) async {
    await collection.doc(place.referenceId).delete();
  }
}
