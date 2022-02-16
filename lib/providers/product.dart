import 'package:flutter/cupertino.dart';

// Defining the products structure and using ChangeNotifier for listening to changes
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    this.isFavourite=false,
    @required this.price,
  });

  // Marks a product as favourite or not
  void toggleFavoriteStatus() {
    isFavourite = !isFavourite;
    notifyListeners();
  }
}
