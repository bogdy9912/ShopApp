import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url =
        'https://shopapp-8dee1.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpException('Favorite not working.');
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
