import 'package:flutter/material.dart';

class Zone {
  final int id;
  final String nomZone;
  final double latitude;
  final double longitude;
  final String niveauRisque;
  final double hauteurEauCm;
  final String? description;
  final String? dernierReleve;

  Zone({
    required this.id,
    required this.nomZone,
    required this.latitude,
    required this.longitude,
    required this.niveauRisque,
    required this.hauteurEauCm,
    this.description,
    this.dernierReleve,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      nomZone: json['nom_zone'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      niveauRisque: json['niveau_risque'],
      hauteurEauCm: json['hauteur_eau_cm'].toDouble(),
      description: json['description'],
      dernierReleve: json['dernier_releve'],
    );
  }

  Color getRiskColor() {
    switch (niveauRisque.toLowerCase()) {
      case 'critique':
        return Colors.red;
      case 'élevé':
        return Colors.orange;
      case 'moyen':
        return Colors.yellow;
      case 'faible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
