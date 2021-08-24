import 'package:flutter/material.dart';
import 'package:price_list_app/widgets/product/product_list_widget.dart';

class ProductListScreen extends StatelessWidget {
  static const String id = 'product-list-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductListWidget(),
    );
  }
}
