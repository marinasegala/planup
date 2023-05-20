import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/shopping.dart';

class ShopRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('shopping');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> add(Shop shop) {
    return collection.add(shop.toJson());
  }

  // 4
  void updateTravel(Shop shop) async {
    await collection.doc(shop.referenceId).update(shop.toJson());
  }

  // 5
  void deleteTravel(Shop shop) async {
    await collection.doc(shop.referenceId).delete();
  }
}
