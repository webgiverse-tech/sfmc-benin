import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/billing/models/invoice_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class BillingService {
  final HttpClient _httpClient = HttpClient();

  Future<List<Facture>> getAllFactures() async {
    final response = await _httpClient.get(ApiConstants.factures);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Facture.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement factures');
  }

  Future<Facture> getFactureById(int id) async {
    final response = await _httpClient.get('${ApiConstants.factures}/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Facture.fromJson(data['data']);
    }
    throw Exception('Facture non trouvée');
  }

  Future<Paiement> addPaiement(int factureId, Paiement paiement) async {
    final response = await _httpClient.put(
      '${ApiConstants.factures}/$factureId/paiement',
      body: jsonEncode(paiement.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Paiement.fromJson(data['paiement']);
    }
    throw Exception('Erreur ajout paiement');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _httpClient.get(ApiConstants.billingStats);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur chargement stats');
  }
}
