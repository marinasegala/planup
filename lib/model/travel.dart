import 'package:cloud_firestore/cloud_firestore.dart';

class Travel {
  String name;
  String? userid;
  String? date;
  List<String>? listPart;
  String? photo;
  int? numFriend;

  String? referenceId;
  // 4
  Travel(this.name,
      {required this.userid,
      required this.date,
      required this.listPart,
      required this.photo,
      required this.numFriend,
      this.referenceId});
  // 5
  factory Travel.fromSnapshot(DocumentSnapshot snapshot) {
    final newTrav = Travel.fromJson(snapshot.data() as Map<String, dynamic>);
    newTrav.referenceId = snapshot.reference.id;
    return newTrav;
  }
  // 6
  factory Travel.fromJson(Map<String, dynamic> json) => _travFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _travToJson(this);

  @override
  String toString() => 'Travel<$name>';
}

Travel _travFromJson(Map<String, dynamic> json) {
  return Travel(
    json['name'] as String,
    userid: json['userid'] as String?,
    date: json['exactly date'] as String?,
    listPart: json['lsit part'] as List<String>?,
    photo: json['photo'] as String?,
    numFriend: json['numFriend'] as int?,
  );
}

Map<String, dynamic> _travToJson(Travel instance) => <String, dynamic>{
      'name': instance.name,
      'userid': instance.userid,
      'exactly date': instance.date,
      'list part': instance.listPart,
      'photo': instance.photo,
      'numFriend': instance.numFriend,
    };
