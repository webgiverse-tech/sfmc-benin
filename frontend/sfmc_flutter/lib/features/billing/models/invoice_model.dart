class Facture {
  final int id;
  final int orderId;
  final int clientId;
  final String? clientNom;
  final double montantTotal;
  final String statut;
  final DateTime dateEmission;
  final DateTime? dateEcheance;
  final double montantPaye;
  final double resteAPayer;
  final List<Paiement>? paiements;

  Facture({
    required this.id,
    required this.orderId,
    required this.clientId,
    this.clientNom,
    required this.montantTotal,
    required this.statut,
    required this.dateEmission,
    this.dateEcheance,
    this.montantPaye = 0,
    this.resteAPayer = 0,
    this.paiements,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'],
      orderId: json['order_id'],
      clientId: json['client_id'],
      clientNom: json['client_nom'],
      montantTotal: json['montant_total'].toDouble(),
      statut: json['statut'],
      dateEmission: DateTime.parse(json['date_emission']),
      dateEcheance: json['date_echeance'] != null
          ? DateTime.parse(json['date_echeance'])
          : null,
      montantPaye: json['montant_paye']?.toDouble() ?? 0,
      resteAPayer: json['reste_a_payer']?.toDouble() ?? 0,
      paiements: json['paiements'] != null
          ? (json['paiements'] as List)
                .map((p) => Paiement.fromJson(p))
                .toList()
          : null,
    );
  }
}

class Paiement {
  final int? id;
  final int factureId;
  final double montant;
  final String mode;
  final DateTime? date;
  final String? reference;

  Paiement({
    this.id,
    required this.factureId,
    required this.montant,
    required this.mode,
    this.date,
    this.reference,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      factureId: json['facture_id'],
      montant: json['montant'].toDouble(),
      mode: json['mode'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'montant': montant, 'mode': mode, 'reference': reference};
  }
}
