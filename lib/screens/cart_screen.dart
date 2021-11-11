import 'package:flutter/material.dart';

import 'package:my_shop/providers/cart.dart' show Cart;
import 'package:my_shop/providers/orders.dart';
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              ?.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) {
              var currentCart = cart.items.values.toList()[index];

              return CartItem(
                  id: currentCart.id,
                  productId: cart.items.keys.toList()[index],
                  title: currentCart.title,
                  quantity: currentCart.quantity,
                  price: currentCart.price);
            },
            itemCount: cart.items.length,
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: widget.cart.totalAmount <= 0
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await Provider.of<Orders>(context, listen: false)
                          .addOrder(widget.cart.items.values.toList(),
                              widget.cart.totalAmount);
                      widget.cart.clear();

                      setState(() {
                        _isLoading = false;
                      });
                    } catch (e) {}
                  },
            child: Text(
              'Order now'.toUpperCase(),
              style: TextStyle(color: Theme.of(context).primaryColor),
            ));
  }
}
