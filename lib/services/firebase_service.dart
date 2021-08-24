import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:price_list_app/screens/home_screen.dart';

class FirebaseServices {
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //-------------------------Show dialog------------------------------
  void showMyDialog(
      {String? title, String? message, required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //người dùng phải nhấn vào button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
//-------------------------Show dialog------------------------------

  deleteCategoryFromDb(String id) async {
    firestore.collection('category').doc(id).delete();
  }

//-----------------dialog confirm delete Banner -------------------
  Future<void> confirmDeleteDialog(
      {String? title,
      String? message,
      BuildContext? context,
      String? id}) async {
    return showDialog<void>(
      context: context!,
      barrierDismissible: false, //người dùng phải nhấn vào button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                deleteCategoryFromDb(id!);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen()),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
