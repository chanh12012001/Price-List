import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryProvider extends ChangeNotifier {
  File? image;
  bool isPicAvail = false;
  String pickerError = '';
  String error = '';
  DocumentSnapshot? categorydetails;
  String? selectedProductCategory;
  String? categoryId;

  Future<String> uploadFile(filePath, name) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('categoryImage/${name}').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu trong DB
    String downloadURL =
        await _storage.ref('categoryImage/${name}').getDownloadURL();
    return downloadURL;
  }

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

  //--------------------Save category data to Firestore-------------------
  Future<void>? saveCategoryDataToDb({String? url, String? categoryName}) {
    DocumentReference _category =
        FirebaseFirestore.instance.collection('category').doc();
    _category.set({
      'categoryName': categoryName,
      'imageUrl': url,
    });
    notifyListeners();
    return null;
  }

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
//--------------------Save category data to Firestore-------------------

  getSelectedStore(DocumentSnapshot? categorydetail) {
    this.categorydetails = categorydetail;
    notifyListeners();
  }

  selectedCategory(category) {
    this.selectedProductCategory = category;
    notifyListeners();
  }

  selectedCategoryId(categoryID) {
    this.categoryId = categoryID;
    notifyListeners();
  }

  //--------------------Update category data to firestore----------------------
  Future<void>? updateCategory(
      {categoryName, context, categoryImage, productId}) {
    CollectionReference _category =
        FirebaseFirestore.instance.collection('category');
    try {
      _category.doc(productId).update({
        'categoryName': categoryName,
        'imageUrl': categoryImage,
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
