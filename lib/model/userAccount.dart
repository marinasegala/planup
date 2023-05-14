import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  String name;
  String email;
  String? userid;

  UserAccount(this.name, this.email, {this.userid});

  factory UserAccount.fromSnapshot(DocumentSnapshot snapshot) {
    final newFriend =
        UserAccount.fromJson(snapshot.data() as Map<String, dynamic>);
    newFriend.userid = snapshot.reference.id;
    return newFriend;
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _userFromJson(json);

  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => 'User<$name>';
}

UserAccount _userFromJson(Map<String, dynamic> json) {
  return UserAccount(
    json['name'] as String,
    json['email'] as String,
  );
}

Map<String, dynamic> _userToJson(UserAccount instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };
