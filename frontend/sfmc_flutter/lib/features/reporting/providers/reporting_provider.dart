import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/reporting/services/reporting_service.dart';

class ReportingProvider extends ChangeNotifier {
  final ReportingService _service = ReportingService();
  bool _isLoading = false;
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _salesData = [];
  Map<String, dynamic> _stockReport = {};
  Map<String, dynamic> _productionReport = {};
  Map<String, dynamic> _financeReport = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic> get dashboardData => _dashboardData;
  List<dynamic> get salesData => _salesData;
  Map<String, dynamic> get stockReport => _stockReport;
  Map<String, dynamic> get productionReport => _productionReport;
  Map<String, dynamic> get financeReport => _financeReport;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _service.getDashboard(),
        _service.getSalesReport(),
        _service.getStockReport(),
        _service.getProductionReport(),
        _service.getFinanceReport(),
      ]);

      _dashboardData = results[0];
      _salesData = results[1];
      _stockReport = results[2];
      _productionReport = results[3];
      _financeReport = results[4];
    } catch (e) {
      // Gérer erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSales({DateTime? start, DateTime? end}) async {
    try {
      _salesData = await _service.getSalesReport(start: start, end: end);
      notifyListeners();
    } catch (e) {
      // Erreur
    }
  }
}
