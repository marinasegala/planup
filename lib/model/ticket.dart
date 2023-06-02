import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String name;
  String? trav;
  String? userid;
  String? url;

  String? referenceId;

  Ticket(this.name,
      {required this.trav,
      required this.userid,
      required this.url,
      this.referenceId});
  // 5
  factory Ticket.fromSnapshot(DocumentSnapshot snapshot) {
    final newShop = Ticket.fromJson(snapshot.data() as Map<String, dynamic>);
    newShop.referenceId = snapshot.reference.id;
    return newShop;
  }
  // 6
  factory Ticket.fromJson(Map<String, dynamic> json) => _shopFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _shopToJson(this);

  @override
  String toString() => 'Ticket<$name>';
}

Ticket _shopFromJson(Map<String, dynamic> json) {
  return Ticket(
    json['name'] as String,
    trav: json['trav'] as String?,
    userid: json['userid'] as String?,
    url: json['url'] as String?
  );
}

Map<String, dynamic> _shopToJson(Ticket instance) => <String, dynamic>{
      'name': instance.name,
      'trav': instance.trav,
      'userid': instance.userid,
      'url': instance.url,
    };
