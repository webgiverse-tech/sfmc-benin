import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/inventory/models/stock_model.dart';
import 'package:sfmc_flutter/features/inventory/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  List<StockItem> _stocks = [];
  List<StockMovement> _movements = [];
  bool _isLoading = false;
  String? _error;

  List<StockItem> get stocks => _stocks;
  List<StockMovement> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get alertsCount =>
      _stocks.where((s) => s.quantity <= s.seuilCritique).length;
  double get totalQuantity => _stocks.fold(0.0, (sum, s) => sum + s.quantity);

  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stocks = await _service.getFullInventory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMovements({Map<String, dynamic>? filters}) async {
    try {
      _movements = await _service.getMovements(filters: filters);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addMovement(StockMovement movement) async {
    try {
      final newMovement = await _service.addMovement(movement);
      _movements.insert(0, newMovement);
      // Rafraîchir les stocks après mouvement
      await fetchInventory();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
