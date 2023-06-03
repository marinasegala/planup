import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String name;
  String? nameFile;
  String? trav;
  String? userid;
  String? url;
  String? ext;

  String? referenceId;

  Ticket(this.name,
      { required this.nameFile,
      required this.trav,
      required this.userid,
      required this.url,
      required this.ext,
      this.referenceId});
  // 5
  factory Ticket.fromSnapshot(DocumentSnapshot snapshot) {
    final newShop = Ticket.fromJson(snapshot.data() as Map<String, dynamic>);
    newShop.referenceId = snapshot.reference.id;
    return newShop;
  }
  // 6
  factory Ticket.fromJson(Map<String, dynamic> json) => _ticketFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _ticketToJson(this);

  @override
  String toString() => 'Ticket<$name>';
}

Ticket _ticketFromJson(Map<String, dynamic> json) {
  return Ticket(
    json['name'] as String,
    nameFile: json['nameFile'] as String?,
    trav: json['trav'] as String?,
    userid: json['userid'] as String?,
    url: json['url'] as String?,
    ext: json['ext'] as String?
  );
}

Map<String, dynamic> _ticketToJson(Ticket instance) => <String, dynamic>{
      'name': instance.name,
      'nameFile': instance.nameFile,
      'trav': instance.trav,
      'userid': instance.userid,
      'url': instance.url,
      'ext': instance.ext
    };
