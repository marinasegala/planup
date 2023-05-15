import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/friend.dart';

class FriendsRepository {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('friends');

  Stream<QuerySnapshot> getStream() {
    return collectionReference.snapshots();
  }

  Future<DocumentReference> addFriend(String userid, String friendid) async {
    // add friend to the collection friends only if the user is not already friend
    if (await isAlreadyFriend(userid, friendid)) {
      return collectionReference.doc(userid);
    } else {
      return collectionReference
          .add(Friend(userid: userid, userIdFriend: friendid).toJson());
    }
  }

  void updateFriend(Friend friend) async {
    await collectionReference.doc(friend.userid).update(friend.toJson());
  }

  void deleteFriend(String id) async {
    await collectionReference.doc(id).delete();
  }

  Future<bool> isAlreadyFriend(String userid, String friendid) async {
    bool isAlreadyFriend = false;
    // return true if the user is already friend
    await collectionReference
        .where('userid', isEqualTo: userid)
        .where('userIdFriend', isEqualTo: friendid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        isAlreadyFriend = true;
      }
    });
    return isAlreadyFriend;
  }
}
