import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_product_screen';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Consumer<Products>(
          builder: (_, data, childWidget) => ListView.builder(
              itemCount: productsData.items.length,
              itemBuilder: (ctx, index) => Column(
                    children: [
                      UserProductItem(productsData.items[index].id, productsData.items[index].title,
                          productsData.items[index].imageUrl),
                      Divider()
                    ],
                  )),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
