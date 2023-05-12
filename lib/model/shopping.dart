import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Shop {
  String name;
  double price;
  String desc;
  String? theme;

  String? userid;

  String? referenceId;
  // 4
  Shop(this.name,
      {required this.price,
      required this.desc,
      required this.theme,
      required this.userid,
      this.referenceId});
  // 5
  factory Shop.fromSnapshot(DocumentSnapshot snapshot) {
    final newTrav = Shop.fromJson(snapshot.data() as Map<String, dynamic>);
    newTrav.referenceId = snapshot.reference.id;
    return newTrav;
  }
  // 6
  factory Shop.fromJson(Map<String, dynamic> json) => _shopFromJson(json);
  // 7
  Map<String, dynamic> toJson() => _shopToJson(this);

  @override
  String toString() => 'Shop<$name>';
}

Shop _shopFromJson(Map<String, dynamic> json) {
  return Shop(
    json['name'] as String,
    price: json['price'] as double,
    desc: json['description'] as String,
    theme: json['theme'] as String?,
    userid: json['userid'] as String?,
  );
}

Map<String, dynamic> _shopToJson(Shop instance) => <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'description': instance.desc,
      'theme': instance.theme,
      'userid': instance.userid,
    };
