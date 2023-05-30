import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String lat;
  String long;
  String userid;
  String travelid;
  String? referenceId;

  Location(this.lat, this.long, this.userid, this.travelid);

  factory Location.fromSnapshot(DocumentSnapshot snapshot) {
    final newLocation =
        Location.fromJson(snapshot.data() as Map<String, dynamic>);
    newLocation.referenceId = snapshot.id;
    return newLocation;
  }

  factory Location.fromJson(Map<String, dynamic> json) => _userFromJson(json);

  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => 'User<$lat, $long, $userid, $travelid>';
}

Location _userFromJson(Map<String, dynamic> json) {
  return Location(
    json['lat'] as String,
    json['long'] as String,
    json['userid'] as String,
    json['travelid'] as String,
  );
}

Map<String, dynamic> _userToJson(Location instance) => <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'userid': instance.userid,
      'travelid': instance.travelid,
    };
