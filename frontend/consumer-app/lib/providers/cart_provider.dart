import 'package:flutter/foundation.dart';

class CartItem {
  final int voucherId;
  final String title;
  final double denomination;
  final int quantity;

  CartItem({
    required this.voucherId,
    required this.title,
    required this.denomination,
    required this.quantity,
  });

  double get total => denomination * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

  void addItem(int voucherId, String title, double denomination) {
    final existingIndex = _items.indexWhere((item) => 
        item.voucherId == voucherId && item.denomination == denomination);

    if (existingIndex >= 0) {
      // Increase quantity
      _items[existingIndex] = CartItem(
        voucherId: voucherId,
        title: title,
        denomination: denomination,
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        voucherId: voucherId,
        title: title,
        denomination: denomination,
        quantity: 1,
      ));
    }

    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}






































