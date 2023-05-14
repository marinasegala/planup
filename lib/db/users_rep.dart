import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool? userExists(String email) {
    collectionReference
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }
}
