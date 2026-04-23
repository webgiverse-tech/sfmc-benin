import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/orders/models/order_model.dart';
import 'package:sfmc_flutter/features/orders/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _filterStatus;

  List<Order> get orders => _orders;
  List<Order> get filteredOrders => _filterStatus == null
      ? _orders
      : _orders.where((o) => o.statut == _filterStatus).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.getAllOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(Order order) async {
    try {
      final newOrder = await _service.createOrder(order);
      _orders.add(newOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final updated = await _service.updateOrderStatus(orderId, newStatus);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    notifyListeners();
  }
}
