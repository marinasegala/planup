import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String lat;
  final String long;
  final String name;
  final String? description;
  final String userid;
  final String travelid;
  String? referenceId;

  Place(
      {required this.lat,
      required this.long,
      required this.name,
      this.description,
      required this.userid,
      required this.travelid});

  factory Place.fromSnapshot(DocumentSnapshot snapshot) {
    final newPlace = Place.fromJson(snapshot.data() as Map<String, dynamic>);
    newPlace.referenceId = snapshot.reference.id;
    return newPlace;
  }

  factory Place.fromJson(Map<String, dynamic> json) => _placeFromJson(json);

  Map<String, dynamic> toJson() => _placeToJson(this);

  @override
  String toString() => 'Place<$name, $lat, $long>';
}

Place _placeFromJson(Map<String, dynamic> json) {
  return Place(
    lat: json['lat'] as String,
    long: json['long'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    userid: json['userid'] as String,
    travelid: json['travelid'] as String,
  );
}

Map<String, dynamic> _placeToJson(Place instance) => <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'name': instance.name,
      'description': instance.description,
      'userid': instance.userid,
      'travelid': instance.travelid,
    };
