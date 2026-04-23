import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/production/models/production_model.dart';
import 'package:sfmc_flutter/features/production/services/production_service.dart';

class ProductionProvider extends ChangeNotifier {
  final ProductionService _service = ProductionService();
  List<ProductionOrder> _orders = [];
  List<Machine> _machines = [];
  bool _isLoading = false;
  String? _error;

  List<ProductionOrder> get orders => _orders;
  List<Machine> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProductionOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.getAllProductionOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMachines() async {
    try {
      _machines = await _service.getMachines();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createProductionOrder(ProductionOrder order) async {
    try {
      final newOrder = await _service.createProductionOrder(order);
      _orders.add(newOrder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(
    int id,
    String status, {
    double? quantityProduced,
  }) async {
    try {
      final updated = await _service.updateProductionStatus(
        id,
        status,
        quantityProduced,
      );
      final index = _orders.indexWhere((o) => o.id == id);
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
}
