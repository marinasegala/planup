import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/userAccount.dart';

class UsersRepository {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getStream() {
    return collectionReference.snapshots();
  }

  Future<DocumentReference> addUser(UserAccount user) {
    return collectionReference.add(user.toJson());
  }

  void updateFriend(UserAccount user) async {
    await collectionReference.doc(user.userid).update(user.toJson());
  }

  void deleteFriend(UserAccount user) async {
    await collectionReference.doc(user.userid).delete();
  }

  Future<bool> userExists(String email) async {
    bool exists = false;
    await collectionReference
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        exists = true;
      } else {
        exists = false;
      }
    });
    return exists;
  }
}
