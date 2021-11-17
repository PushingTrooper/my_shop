import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_shop/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<OrderItem> orders) {
    _token = token;
    _userId = userId;
    _orders = orders;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');

    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) return;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>)
            .map((item) => CartItem(
                id: item['id'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price']))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');

    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: jsonEncode({
          'amount': total,
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String()
        }));

    _orders.insert(
        0,
        OrderItem(
            id: jsonDecode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp));
    notifyListeners();
  }
}
