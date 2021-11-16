import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String _userId;

  Future<void> _authenticate(
      String email, String password, String endpoint) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$endpoint?key=AIzaSyBrBCJL9C_knpecI89e3By9yfQvbzh6Cko');

    try {
      final response = await http.post(url,
          body: jsonEncode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      print(response.body);

      final rData = jsonDecode(response.body);
      if (rData['error'] != null) {
        throw HttpException(rData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}