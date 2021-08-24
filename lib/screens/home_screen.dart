import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:price_list_app/widgets/category/category_pic_card.dart';
import 'package:price_list_app/widgets/category/category_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home-screen';
  final _categoryNameContoller = TextEditingController();

  void showBottomSheet(context) {
    Future<String> uploadFile(filePath) async {
      File file = File(filePath);
      FirebaseStorage _storage = FirebaseStorage.instance;

      try {
        await _storage
            .ref('categoryImage/${_categoryNameContoller.text}')
            .putFile(file);
      } on FirebaseException catch (e) {
        print(e.code);
      }

      //Sau khi tải tệp lên, cần đến đường dẫn url của tệp để lưu trong DB
      String downloadURL = await _storage
          .ref('categoryImage/${_categoryNameContoller.text}')
          .getDownloadURL();
      return downloadURL;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, StateSetter setState) {
          final _categoryProvider = Provider.of<CategoryProvider>(context);

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'THÊM DANH MỤC SẢN PHẨM',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CategoryPicCard(),
                    TextField(
                      controller: _categoryNameContoller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelText: 'Tên danh mục',
                      ),
                      //keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        if (_categoryProvider.isPicAvail == true) {
                          EasyLoading.show(status: 'Đang lưu...');
                          //Đầu tiên sẽ xác nhận ảnh hồ sơ
                          uploadFile(_categoryProvider.image!.path).then((url) {
                            // ignore: unnecessary_null_comparison
                            if (url != null) {
                              final snackBar =
                                  SnackBar(content: Text('Lưu thành công'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              EasyLoading.dismiss();
                              //Lưu mô tả shop vào DB
                              _categoryProvider.saveCategoryDataToDb(
                                url: url,
                                categoryName: _categoryNameContoller.text,
                              );
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HomeScreen()),
                                  (route) => false);
                            } else {
                              print('thất bại');
                            }
                          });
                        } else {
                          print('cần thêm ảnh');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          'Thêm danh mục sản phẩm',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.teal),
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.teal.shade600),
                        shape:
                            MaterialStateProperty.resolveWith<OutlinedBorder>(
                                (_) {
                          return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/gif_icon1.gif'),
            Text(
              'LOẠI SẢN PHẨM',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset('assets/images/gif_icon2.gif'),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Colors.red, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: Colors.teal,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
      ),
      body: CategoriesWidget(),
    );
  }
}
