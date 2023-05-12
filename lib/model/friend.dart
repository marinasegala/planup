import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String? id;
  String? userid;
  String? userIdFriend;

  Friend({this.userid, this.userIdFriend});

  factory Friend.fromSnapshot(DocumentSnapshot snapshot) {
    final newFriend = Friend.fromJson(snapshot.data() as Map<String, dynamic>);
    newFriend.id = snapshot.reference.id;
    return newFriend;
  }

  factory Friend.fromJson(Map<String, dynamic> json) => _friendFromJson(json);

  Map<String, dynamic> toJson() => _friendToJson(this);

  @override
  String toString() => 'Friend<$userid, $userIdFriend>';
}

Friend _friendFromJson(Map<String, dynamic> json) {
  return Friend(
    userid: json['userid'] as String?,
    userIdFriend: json['userIdFriend'] as String?,
  );
}

Map<String, dynamic> _friendToJson(Friend instance) => <String, dynamic>{
      'userid': instance.userid,
      'userIdFriend': instance.userIdFriend,
    };
