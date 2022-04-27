import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exceptions.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // final url = Uri.https(
    //   'shop-app-d0404-default-rtdb.firebaseio.com',
    //   '/products.json?auth=$authToken',
    // );
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    Uri url = Uri.parse(
        'https://shop-app-d0404-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://shop-app-d0404-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            isFavorite: favouriteData == null
                ? false
                : favouriteData[productId] ?? false,
            imageUrl: productData['imageUrl'],
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    Uri url = Uri.parse(
        'https://shop-app-d0404-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // final url = Uri.https(
      //   'shop-app-d0404-default-rtdb.firebaseio.com',
      //   '/products/$id.json',
      // );

      Uri url = Uri.parse(
          'https://shop-app-d0404-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    Uri url = Uri.parse(
        'https://shop-app-d0404-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final exisitingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var exisitingProduct = _items[exisitingProductIndex];
    _items.removeAt(exisitingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(exisitingProductIndex, exisitingProduct);
      notifyListeners();
      throw HttpEception('Could Not Delete Product.');
    }
    exisitingProduct = null;
  }
}
