import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:price_list_app/providers/product_provider.dart';
import 'package:price_list_app/screens/product_list_screen.dart';
import 'package:price_list_app/services/product_service.dart';
import 'package:price_list_app/widgets/product/product_card_widget.dart';
import 'package:price_list_app/widgets/product/product_pic_card.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatefulWidget {
  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();

    var _category = Provider.of<CategoryProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future: _services.products
          .where('categoryId', isEqualTo: _category.categoryId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Đã xảy ra sự cố');
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            AppBar(
              title: Text(snapshot.data!.size != 0
                  ? _category.selectedProductCategory.toString()
                  : 'Chưa có sản phẩm'),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialogAddProduct(context);
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '${snapshot.data!.docs.length} sản phẩm',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 550,
              child: new ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return new ProductCard(document);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  var _productNameController = TextEditingController();
  var _retailPriceController = TextEditingController();
  var _wholesalePriceController = TextEditingController();
  DocumentSnapshot? doc;

  void showDialogAddProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final _productProvider = Provider.of<ProductProvider>(context);
        final _category = Provider.of<CategoryProvider>(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Center(
            child: Text(
              'THÊM SẢN PHẨM',
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
                  ProductPicCard(),
                  TextField(
                    controller: _productNameController,
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
                    controller: _retailPriceController,
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
                    controller: _wholesalePriceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Giá bán sỉ',
                    ),
                    //keyboardType: TextInputType.,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_productNameController.text.isNotEmpty) {
                        //chỉ khi điền trường cần thiết
                        if (_retailPriceController.text.isNotEmpty) {
                          EasyLoading.show(status: 'Đang lưu...');
                          if (_wholesalePriceController.text.isNotEmpty) {
                            if (_productProvider.image != null) {
                              //upload ảnh lên storage
                              _productProvider
                                  .uploadProductImage(
                                _productProvider.image!.path,
                                _productNameController.text,
                                _category.selectedProductCategory.toString(),
                              )
                                  .then((url) {
                                EasyLoading.dismiss();
                                setState(() {
                                  Navigator.pushReplacementNamed(
                                      context, ProductListScreen.id);
                                  Navigator.pop(context);
                                });
                                // ignore: unnecessary_null_comparison
                                if (url != null) {
                                  //upload dữ liệu sản phẩm lên firestore
                                  _productProvider.saveProductDataToDb(
                                    context: context,
                                    categoryId: _category.categoryId,
                                    productName: _productNameController.text,
                                    retailPrice: _retailPriceController.text,
                                    wholesalePrice:
                                        _wholesalePriceController.text,
                                  );
                                  // xóa tất cả giá trị hiện có sau khi sản phẩm được lưu
                                  _productNameController.text = '';
                                  _retailPriceController.text = '';
                                  _wholesalePriceController.text = '';
                                } else {
                                  //Upload thất bại
                                  print('falled');
                                }
                              });
                            } else {
                              //image not selected
                              print('image not selected');
                            }
                          } else {
                            print('chua nhap gia si');
                          }
                        } else {
                          print('chua nhap gia');
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        'Thêm',
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
