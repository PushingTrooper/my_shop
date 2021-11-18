import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem({Key? key, required this.order}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd MM yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                  _expanded ? _controller.forward() : _controller.reverse();
                });
              },
            ),
          ),
          AnimatedContainer(
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 250),
            constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: _expanded ? min((widget.order.products.length * 10 + 50), 180) : 0),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ListView.builder(
                  itemCount: widget.order.products.length,
                  itemBuilder: (ctx, index) {
                    var product = widget.order.products[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${product.quantity}x \$ ${product.price}',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            )
                          ]),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
