import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  File? image;
  bool isPicAvail = false;
  String pickerError = '';
  String? productUrl;

  //-----------------------Reduce image size-----------------------------
  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        // ignore: deprecated_member_use
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'Không có ảnh nào được chọn.';
      notifyListeners();
    }
    return this.image!;
  }
  //-----------------------Reduce image size-----------------------------

//--------------------Upload product image----------------------------
  Future<String> uploadProductImage(filePath, productName, categoryName) async {
    File file = File(filePath); //Đường dẫn tệp tải lên
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage
          .ref('productImage/$categoryName/$productName$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu vào DB
    String downloadURL = await _storage
        .ref('productImage/$categoryName/$productName$timeStamp')
        .getDownloadURL();
    this.productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }
  //--------------------Upload product image----------------------------

  //----------------------------Dialog---------------------------------
  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  //----------------------------Dialog---------------------------------

  //----------------------Save product data to firestore----------------------
  Future<void>? saveProductDataToDb(
      {productName, retailPrice, wholesalePrice, categoryId, context}) {
    var timeStamp =
        DateTime.now().microsecondsSinceEpoch; //dùng làm ID sản phẩm
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    try {
      _products.doc(timeStamp.toString()).set({
        'productName': productName,
        'retailPrice': retailPrice,
        'wholesalePrice': wholesalePrice,
        'categoryId': categoryId,
        'image': this.productUrl
      });
      this.alertDialog(
        context: context,
        title: 'LƯU DỮ LIỆU',
        content: 'Lưu thành công sản phẩm!',
      );
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
    return null;
  }
//----------------------Save product data to firestore----------------------

//--------------------Update category data to firestore----------------------
  Future<void>? updateProduct(
      {productName,
      context,
      productImage,
      productId,
      retailPrice,
      wholesalePrice}) {
    CollectionReference _category =
        FirebaseFirestore.instance.collection('products');
    try {
      _category.doc(productId).update({
        'productName': productName,
        'retailPrice': retailPrice,
        'wholesalePrice': wholesalePrice,
        'image': productImage,
      });
      this.alertDialog(
        context: context,
        title: 'CẬP NHẬT DỮ LIỆU',
        content: 'Cập nhật thành công!',
      );
      notifyListeners();
    } catch (e) {
      this.alertDialog(
          context: context,
          title: 'CẬP NHẬT DỮ LIỆU',
          content: '${e.toString()}');
    }
    return null;
  }
  //--------------------Update product data to firestore----------------------

}
