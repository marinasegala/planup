import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String name;
  Image? image;
  String? userid;

  Friend(this.name, {this.image, this.userid});

  factory Friend.fromSnapshot(DocumentSnapshot snapshot) {
    final newFriend = Friend.fromJson(snapshot.data() as Map<String, dynamic>);
    newFriend.userid = snapshot.reference.id;
    return newFriend;
  }

  factory Friend.fromJson(Map<String, dynamic> json) => _friendFromJson(json);

  Map<String, dynamic> toJson() => _friendToJson(this);

  @override
  String toString() => 'Friend<$name>';
}

Friend _friendFromJson(Map<String, dynamic> json) {
  return Friend(
    json['name'] as String,
    userid: json['userid'] as String?,
  );
}

Map<String, dynamic> _friendToJson(Friend instance) => <String, dynamic>{
      'name': instance.name,
      'userid': instance.userid,
    };
