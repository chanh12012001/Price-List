import 'dart:io';
import 'package:flutter/material.dart';
import 'package:price_list_app/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductPicCard extends StatefulWidget {
  @override
  _ProductPicCardState createState() => _ProductPicCardState();
}

class _ProductPicCardState extends State<ProductPicCard> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    final _productData = Provider.of<ProductProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          _productData.getImage().then((image) {
            setState(() {
              _image = image;
            });
            // ignore: unnecessary_null_comparison
            if (image != null) {
              _productData.isPicAvail = true;
            }
          });
        },
        child: SizedBox(
          height: 150,
          width: 150,
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _image == null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Vui lòng nhấp vào để chọn ảnh',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center),
                ),
              )
                  : Image.file(
                _image!,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
