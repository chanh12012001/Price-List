import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:price_list_app/providers/product_provider.dart';
import 'package:price_list_app/screens/product_list_screen.dart';
import 'package:price_list_app/services/product_service.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  final DocumentSnapshot document;
  ProductCard(this.document);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  var _nameProduct = TextEditingController();
  var _retailPrice = TextEditingController();
  var _wholesalePrice = TextEditingController();
  String? image;
  File? _image;

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Sửa',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            showDialogUpdateProduct(context);
            _nameProduct.text = widget.document['productName'];
            _retailPrice.text = widget.document['retailPrice'];
            _wholesalePrice.text = widget.document['wholesalePrice'];
            image = widget.document['image'];
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
              title: 'Xóa sản phẩm',
              id: widget.document.id,
            );
          },
        ),
      ],
      child: Container(
        height: 155,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1, color: Colors.grey.shade400))),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
          child: Row(
            children: [
              Stack(
                children: [
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 140,
                      width: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Hero(
                          tag: 'Sản phẩm${widget.document['productName']}',
                          child: Image.network(widget.document['image']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.document['productName'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 160,
                            padding:
                                EdgeInsets.only(top: 10, bottom: 10, left: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: Text(
                              'Giá lẻ: ' +
                                  widget.document['retailPrice'] +
                                  ' đồng',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              'Giá sỉ: ' +
                                  widget.document['wholesalePrice'] +
                                  ' đồng',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showDialogUpdateProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final _product = Provider.of<ProductProvider>(context);
        final _category = Provider.of<CategoryProvider>(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Center(
            child: Text(
              'CẬP NHẬT SẢN PHẨM',
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
                      _product.getImage().then((images) {
                        setState(() {
                          this._image = images;
                        });
                        print(_image!.uri);
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
                    height: 10,
                  ),
                  TextField(
                    controller: _nameProduct,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Tên sản phẩm',
                    ),
                    //keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _retailPrice,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Giá bán lẻ',
                    ),
                    //keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _wholesalePrice,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Giá bán sỉ',
                    ),
                    //keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_image != null) {
                        EasyLoading.show(status: 'Đang lưu...');
                        _product
                            .uploadProductImage(_image!.path, _nameProduct.text,
                                _category.selectedProductCategory)
                            .then((url) {
                          EasyLoading.dismiss();
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                                context, ProductListScreen.id);
                          });

                          _product.updateProduct(
                            context: context,
                            productName: _nameProduct.text,
                            productImage: url,
                            productId: widget.document.id,
                            retailPrice: _retailPrice.text,
                            wholesalePrice: _wholesalePrice.text,
                          );
                        });
                      } else {
                        setState(() {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(
                              context, ProductListScreen.id);
                        });
                        _product.updateProduct(
                          context: context,
                          productName: _nameProduct.text,
                          productImage: image,
                          productId: widget.document.id,
                          retailPrice: _retailPrice.text,
                          wholesalePrice: _wholesalePrice.text,
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
