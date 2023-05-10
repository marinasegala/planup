import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/friend.dart';

class FriendsRepository {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('friends');

  Stream<QuerySnapshot> getStream() {
    return collectionReference.snapshots();
  }

  Future<DocumentReference> addFriend(Friend friend) {
    return collectionReference.add(friend.toJson());
  }

  void updateFriend(Friend friend) async {
    await collectionReference.doc(friend.userid).update(friend.toJson());
  }

  void deleteFriend(Friend friend) async {
    await collectionReference.doc(friend.userid).delete();
  }
}
