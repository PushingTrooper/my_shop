import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // )
  ];

  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<Product> products) {
    _token = token;
    _userId = userId;
    _items = products;
  }

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterEnd =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    final url = Uri.parse(
        'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_token&$filterEnd');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>?;

      final favoriteUrl = Uri.parse(
          'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$_userId.json?auth=$_token');
      final favoritesResponse = await http.get(favoriteUrl);
      final favoriteData =
          jsonDecode(favoritesResponse.body) as Map<String, dynamic>?;

      final List<Product> loadedProducts = [];
      if (data != null) {
        for (var i = 0; i < data.length; i++) {
          String prodId = data.keys.elementAt(i);
          dynamic prodData = data.values.elementAt(i);
          loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: favoriteData == null
                  ? false
                  : (favoriteData[prodId] ?? false)));
        }
      }
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$_token');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'creatorId': _userId
        }),
      );
      var body = json.decode(response.body);

      final newProduct = Product(
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          id: body['name']);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_token');
      await http.patch(url,
          body: jsonEncode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      //
    }
  }

  Future<void> deleteProduct(String id) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shopping-app-42a56-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$_token');

      Product? removedItem = _items[prodIndex];
      _items.removeAt(prodIndex);
      notifyListeners();
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(prodIndex, removedItem);
        notifyListeners();
        throw HttpException('Could not delete product.');
      }
      removedItem = null;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }
}
