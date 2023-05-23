import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  String name;
  String email;
  final String? userid;
  String? photoUrl;

  UserAccount(this.name, this.email, this.userid, this.photoUrl);

  factory UserAccount.fromSnapshot(DocumentSnapshot snapshot) {
    final newFriend =
        UserAccount.fromJson(snapshot.data() as Map<String, dynamic>);
    return newFriend;
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _userFromJson(json);

  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => 'User<$name, $email, $userid>';
}

UserAccount _userFromJson(Map<String, dynamic> json) {
  return UserAccount(
    json['name'] as String,
    json['email'] as String,
    json['userid'] as String?,
    json['photoUrl'] as String?,
  );
}

Map<String, dynamic> _userToJson(UserAccount instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'userid': instance.userid,
      'photoUrl': instance.photoUrl,
    };
