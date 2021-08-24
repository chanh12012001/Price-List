import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:price_list_app/screens/product_list_screen.dart';

class ProductServices {
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  deleteProductFromDb(String id) async {
    firestore.collection('products').doc(id).delete();
  }

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
                deleteProductFromDb(id!);
                Navigator.pop(context);
                final snackBar = SnackBar(content: Text('Xoá thành công'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pushReplacementNamed(context, ProductListScreen.id);
              },
            ),
          ],
        );
      },
    );
  }
}
