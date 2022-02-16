import 'package:flutter/cupertino.dart';

import './cart.dart';

// Structure of an Order
class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.amount,
    @required this.dateTime,
    @required this.id,
    @required this.products,
  });
}

// Actual Orders that will be used
class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  // Returns all current orders
  List<OrderItem> get orders {
    return [..._orders];
  }

  // This function creates the order and stores it into the orders array
  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        amount: total,
        dateTime: DateTime.now(),
        id: DateTime.now().toString(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
