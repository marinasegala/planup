import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/friend.dart';

class FriendsRepository {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('friends');

  Stream<QuerySnapshot> getStream() {
    return collectionReference.snapshots();
  }

  Future<DocumentReference> addFriend(String userid, String friendid) async {
    final friend = Friend(userid: userid, userIdFriend: friendid);
    return await collectionReference.add(friend.toJson());
  }

  void updateFriend(Friend friend) async {
    await collectionReference.doc(friend.userid).update(friend.toJson());
  }

  void deleteFriend(String id) async {
    await collectionReference.doc(id).delete();
  }
}
