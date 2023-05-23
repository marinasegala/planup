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

  Future<List<Place>> getPlaces() async {
    List<Place> users = [];
    await collection.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        users.add(Place(
            lat: element['lat'],
            long: element['long'],
            name: element['name'],
            description: element['description'],
            userid: element['userid'],
            travelid: element['travelid']));
      }
    });
    return users;
  }
}
