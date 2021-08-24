import 'dart:io';
import 'package:flutter/material.dart';
import 'package:price_list_app/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryPicCard extends StatefulWidget {
  @override
  _CategoryPicCardState createState() => _CategoryPicCardState();
}

class _CategoryPicCardState extends State<CategoryPicCard> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    final _categoryData = Provider.of<CategoryProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          _categoryData.getImage().then((image) {
            setState(() {
              _image = image;
            });
            // ignore: unnecessary_null_comparison
            if (image != null) {
              _categoryData.isPicAvail = true;
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
