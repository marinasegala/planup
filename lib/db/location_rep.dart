import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/location.dart';

class LocationRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('location');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Location location) {
    return collection.add(location.toJson());
  }

  // 4
  void updateLocation(String userid, String travelid, Location location) async {
    await FirebaseFirestore.instance
        .collection('location')
        .where('userid', isEqualTo: userid)
        .where('travelid', isEqualTo: travelid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update(location.toJson());
      }
    });
  }

  // 5
  void deleteLocation(String userid, String travelid) async {
    await FirebaseFirestore.instance
        .collection('location')
        .where('userid', isEqualTo: userid)
        .where('travelid', isEqualTo: travelid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> isAlreadyShared(String userid, String travelid) async {
    bool isAlreadyShared = false;
    // return true if the location is already shared
    await collection
        .where('userid', isEqualTo: userid)
        .where('travelid', isEqualTo: travelid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        isAlreadyShared = true;
      }
    });
    return isAlreadyShared;
  }
}
