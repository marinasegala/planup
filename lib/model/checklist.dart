import 'package:cloud_firestore/cloud_firestore.dart';

class Check {
  String name;
  String? trav;
  String? userid;

  String? referenceId;
 
  Check(this.name,
      {required this.trav,
      required this.userid,
      this.referenceId});
  // 5
  factory Check.fromSnapshot(DocumentSnapshot snapshot) {
    final newchecklist = Check.fromJson(snapshot.data() as Map<String, dynamic>);
    newchecklist.referenceId = snapshot.reference.id;
    return newchecklist;
  }
  // 6
  factory Check.fromJson(Map<String, dynamic> json) => _shopFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _shopToJson(this);

  @override
  String toString() => 'Note<$name>';
}

Check _shopFromJson(Map<String, dynamic> json) {
  return Check(
    json['name'] as String,
    trav: json['trav'] as String?,
    userid: json['userid'] as String?,
  );
}

Map<String, dynamic> _shopToJson(Check instance) => <String, dynamic>{
      'name': instance.name,
      'trav': instance.trav,
      'userid': instance.userid,
    };
