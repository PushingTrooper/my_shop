import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl);

  //Future<void> deleteProduct() async

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: Icon(Icons.edit)),
          IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                } catch (e) {
                  scaffold.showSnackBar(
                      SnackBar(content: Text('Deleting failed!')));
                }
              },
              icon: Icon(Icons.delete)),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
