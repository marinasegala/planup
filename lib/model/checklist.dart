import 'package:cloud_firestore/cloud_firestore.dart';

class Check {
  String name; //nome oggetto da portare
  String? trav; //riferimento del viaggio
  String? creator; //chi ha scritto
  bool isgroup; //true - oggetto da inserire nella lista comune; false - oggetto personale 
  bool isPublic; //true - lista personale pubblica; false - privata 
  bool isChecked;
  String whoBring;

  String? referenceId;
 
  Check(this.name,
      {required this.trav,
      required this.creator,
      required this.isgroup,
      required this.isPublic,
      required this.isChecked,
      required this.whoBring,
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
    creator: json['creator'] as String?,
    isgroup: json['isgroup'] as bool,
    isPublic: json['isPublic'] as bool,
    isChecked: json['isChecked'] as bool,
    whoBring: json['whoBring'] as String,
  );
}

Map<String, dynamic> _shopToJson(Check instance) => <String, dynamic>{
      'name': instance.name,
      'trav': instance.trav,
      'creator': instance.creator,
      'isgroup': instance.isgroup,
      'isPublic': instance.isPublic,
      'isChecked': instance.isChecked,
      'whoBring': instance.whoBring,
    };
