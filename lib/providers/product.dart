import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite = false;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  void toggleFavoriteStatus(String token, String userId) {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    http.put(url, body: jsonEncode(isFavorite)).then((response) {
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    }).catchError((error) {
      isFavorite = oldStatus;
      notifyListeners();
    });
  }
}
