import 'package:flutter/cupertino.dart';

// Defining the CartItem structure for our items inside the cart for uniformity
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

// This is the actual class that will work as Cart and since we have used it with ChangeNotifier so we can listen to any changes that might have happen in it
class Cart with ChangeNotifier {
  // This Map contains the items that are currently present in the cart
  Map<String, CartItem> _items = {};

  // this getter method sends a copy of the Map which contains our cart items
  Map<String, CartItem> get items {
    return {..._items};
  }

  // This returns the number of items in the cart which will be displayed upon the cart icon
  int get itemCount {
    return _items.length;
  }

  // this returns the total price for items in the cart
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartitem) {
      total += (cartitem.price * cartitem.quantity);
    });
    return total;
  }

  // This function is responsible for adding new items to the cart
  // it looks into the cart map and if there is alredy any item of that category than just simply update the quantity of the product
  // else it creates the new product and store in the map
  // finally it calls notifyListners to tell listners that i have changed and build method runs again and chnages are reflected on the UI
  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (cartItem) => CartItem(
          id: cartItem.id,
          title: cartItem.title,
          price: cartItem.price,
          quantity: cartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Simply remove and notifyListners
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // This will be used when we order an item, all current items in the cart will be transferred to order and cart is cleared
  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
