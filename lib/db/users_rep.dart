import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planup/model/user_account.dart';

class UsersRepository {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getStream() {
    return collectionReference.snapshots();
  }

  Future<DocumentReference> addUser(UserAccount user) {
    return collectionReference.add(user.toJson());
  }

  void updateUser(UserAccount user) async {
    await collectionReference.doc(user.userid).update(user.toJson());
  }

  void deleteUser(UserAccount user) async {
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

  Future<List<UserAccount>> getUsers() async {
    List<UserAccount> users = [];
    await collectionReference.get().then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        users.add(UserAccount(element['name'], element['email'],
            element['userid'], element['photoUrl']));
      }
    });
    return users;
  }

  void updateUserLocation(UserAccount user, String location) {
    collectionReference.doc(user.userid).update({'position': location});
  }
}
