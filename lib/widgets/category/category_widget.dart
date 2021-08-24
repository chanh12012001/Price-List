import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:price_list_app/services/product_service.dart';
import 'package:price_list_app/widgets/category/category_item_widget.dart';
import 'package:provider/provider.dart';

class CategoriesWidget extends StatefulWidget {
  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  List _catList = [];

  @override
  void didChangeDependencies() {
    var _categoryProvider = Provider.of<CategoryProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: _categoryProvider.categoryId)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (mounted) {
                  setState(() {
                    _catList.add(doc['categoryId']);
                  });
                }
              }),
            });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();

    return FutureBuilder(
        future: _services.category.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra sự cố..'));
          }
          if (_catList.length == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Container();
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new GridView(
                    scrollDirection: Axis.vertical,
                    addAutomaticKeepAlives: false,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return new CategoryWidget(document);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
