import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Travel {
  
  String name;
  String partecipant;
  String? userid;
  String? date;

  String? referenceId;
  // 4
  Travel(this.name,
      {required this.partecipant, 
       required this.userid, 
       required this.date,
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
  return Travel(json['name'] as String,
      partecipant: json['partecipant'] as String,
      userid: json['userid'] as String?,
      date: json['exactly date'] as String?,
  );
}

Map<String, dynamic> _travToJson(Travel instance) => <String, dynamic>{
    'name': instance.name,
    'partecipant': instance.partecipant,  
    'userid': instance.userid,
    'exactly date': instance.date,
  };