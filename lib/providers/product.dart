import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop_app/models/http_exceptions.dart';

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

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.https(
      'shop-app-d0404-default-rtdb.firebaseio.com',
      '/products/$id.json',
    );
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.patch(
      url,
      body: json.encode(
        {
          'isFavorite': isFavorite,
        },
      ),
    );

    if (response.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
      throw HttpEception('Could Not Change To Favourite');
    }
  }
}
