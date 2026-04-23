import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/billing/models/invoice_model.dart';
import 'package:sfmc_flutter/features/billing/services/billing_service.dart';

class BillingProvider extends ChangeNotifier {
  final BillingService _service = BillingService();
  List<Facture> _factures = [];
  bool _isLoading = false;
  String? _error;
  String? _filterStatus;

  List<Facture> get factures => _factures;
  List<Facture> get filteredFactures => _filterStatus == null
      ? _factures
      : _factures.where((f) => f.statut == _filterStatus).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFactures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _factures = await _service.getAllFactures();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPaiement(int factureId, Paiement paiement) async {
    try {
      final newPaiement = await _service.addPaiement(factureId, paiement);
      // Mettre à jour la facture dans la liste
      await fetchFactures();
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
