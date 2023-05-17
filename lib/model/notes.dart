import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String name;
  String? trav;
  String desc;
  String? userid;

  String? referenceId;
 
  Note(this.name,
      {required this.trav,
      required this.desc,
      required this.userid,
      this.referenceId});
  // 5
  factory Note.fromSnapshot(DocumentSnapshot snapshot) {
    final newShop = Note.fromJson(snapshot.data() as Map<String, dynamic>);
    newShop.referenceId = snapshot.reference.id;
    return newShop;
  }
  // 6
  factory Note.fromJson(Map<String, dynamic> json) => _shopFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _shopToJson(this);

  @override
  String toString() => 'Note<$name>';
}

Note _shopFromJson(Map<String, dynamic> json) {
  return Note(
    json['name'] as String,
    trav: json['trav'] as String?,
    desc: json['desc'] as String,
    userid: json['userid'] as String?,
  );
}

Map<String, dynamic> _shopToJson(Note instance) => <String, dynamic>{
      'name': instance.name,
      'trav': instance.trav,
      'desc': instance.desc,
      'userid': instance.userid,
    };
