import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/travel_info.dart';

class ItemListWidget extends StatelessWidget {
  DocumentSnapshot snapshot;
  ItemListWidget({Key? key, required this.snapshot})
      : super(key: key);

  
  Future<void> updateItem(String field, bool newField, String id) {
    return FirebaseFirestore.instance
        .collection('check')
        .doc(id)
        .update({field: newField}).then(
            (value) => print("Update")
            ,onError: (e) => print("Error updating doc: $e")
        );
  }

  @override
  Widget build(BuildContext context) {
    return  CheckboxListTile(
      value: snapshot.get('isChecked'),
      onChanged: (bool? value) {
        updateItem('isChecked', value!, snapshot.id);
      },
      title: Text(snapshot.get('name')),);
  }
}
