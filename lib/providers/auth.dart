import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  late String _userId;
  Timer? _authTimer;
  bool get isAuth {
    return token != null;
  }

  String? get token {
    if ((_expiryDate?.isAfter(DateTime.now()) ?? false) && _token != null) {
      return _token!;
    }
    return null;
  }

  String? get userId {
    if (_token != null) {
      return _userId;
    }
    return null;
  }

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

      final rData = jsonDecode(response.body);
      if (rData['error'] != null) {
        throw HttpException(rData['error']['message']);
      }
      _token = rData['idToken'];
      _userId = rData['localId'];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(rData['expiresIn'])));
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        "userId": _userId,
        "expiryDate": _expiryDate!.toIso8601String()
      });
      prefs.setString('userData', userData);
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

  void logout() async {
    _token = null;
    _expiryDate = null;

    _authTimer?.cancel();
    _authTimer = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
  }

  void _autoLogout() {
    _authTimer?.cancel();

    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: (timeToExpiry != null ? timeToExpiry : 0)), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }

    final userData =
        jsonDecode(prefs.getString("userData")!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isAfter(DateTime.now())) {
      _token = userData['token'];
      _userId = userData['userId'];
      _expiryDate = expiryDate;
      notifyListeners();
      _autoLogout();

      return true;
    } else
      return false;
  }
}
