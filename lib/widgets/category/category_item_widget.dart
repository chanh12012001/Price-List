import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:price_list_app/screens/home_screen.dart';
import 'package:price_list_app/screens/product_list_screen.dart';
import 'package:price_list_app/services/firebase_service.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  final DocumentSnapshot document;
  CategoryWidget(this.document);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  var _nameCategory = TextEditingController();
  String? image;
  File? _image;
  String? categoryId;

  @override
  Widget build(BuildContext context) {
    var _categoryProvider = Provider.of<CategoryProvider>(context);
    FirebaseServices _services = FirebaseServices();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Sửa',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () {
              setState(() {
                categoryId = widget.document.id;
                image = widget.document['imageUrl'];
                _nameCategory.text = widget.document['categoryName'];
              });
              showDialogUpdateCategory(context);
            },
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Xóa',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              _services.confirmDeleteDialog(
                context: context,
                message: 'Bạn có chắc chắn muốn xóa ?',
                title: 'Xóa danh mục',
                id: widget.document.id,
              );
            },
          ),
        ],
        child: InkWell(
          onTap: () {
            _categoryProvider.selectedCategoryId(widget.document.id);
            _categoryProvider.selectedCategory(widget.document['categoryName']);
            pushNewScreenWithRouteSettings(
              context,
              settings: RouteSettings(name: ProductListScreen.id),
              screen: ProductListScreen(),
              withNavBar: true,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Container(
            margin: EdgeInsets.all(5),
            height: 170,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(widget.document['imageUrl'],
                        fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(widget.document['categoryName'],
                            style: TextStyle(color: Colors.white, fontSize: 25))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDialogUpdateCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final _category = Provider.of<CategoryProvider>(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Center(
            child: Text(
              'SỬA DANH MỤC',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      _category.getImage().then((images) {
                        setState(() {
                          this._image = images;
                        });
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _image != null
                            ? Image.file(
                                _image!,
                                height: 300,
                                fit: BoxFit.fill,
                              )
                            : Image.network(
                                image!,
                                height: 300,
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _nameCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Tên danh mục',
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_image != null) {
                        _category
                            .uploadFile(_image!.path, _nameCategory.text)
                            .then((url) {
                          setState(() {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        HomeScreen()),
                                (route) => false);
                            // Navigator.pop(context);
                          });
                          _category.updateCategory(
                            context: context,
                            categoryName: _nameCategory.text,
                            categoryImage: url,
                            productId: widget.document.id,
                          );
                        });
                      } else {
                        setState(() {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomeScreen()),
                              (route) => false);
                        });
                        _category.updateCategory(
                          context: context,
                          categoryName: _nameCategory.text,
                          categoryImage: image,
                          productId: widget.document.id,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        'Cập nhật',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                      overlayColor: MaterialStateProperty.all<Color>(
                          Colors.teal.shade600),
                      shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
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
    );
  }
}
