import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String? userid;
  final String? userIdFriend;

  Friend({this.userid, this.userIdFriend});

  factory Friend.fromSnapshot(DocumentSnapshot snapshot) {
    final newFriend = Friend.fromJson(snapshot.data() as Map<String, dynamic>);
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
