import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  static String routeName = "/productDetail";

  // final String title;

  // const ProductDetailScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    //...

    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
    );
  }
}
