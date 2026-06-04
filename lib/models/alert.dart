import 'package:flutter/material.dart';

class Alert {
  final int id;
  final int zoneId;
  final String? nomZone;
  final String message;
  final String niveau;
  final String dateAlerte;
  final bool? estLue;

  Alert({
    required this.id,
    required this.zoneId,
    this.nomZone,
    required this.message,
    required this.niveau,
    required this.dateAlerte,
    this.estLue,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      zoneId: json['zone_id'],
      nomZone: json['nom_zone'],
      message: json['message'],
      niveau: json['niveau'],
      dateAlerte: json['date_alerte'],
      estLue: json['est_lue'],
    );
  }

  Color getNiveauColor() {
    switch (niveau.toLowerCase()) {
      case 'crue_majeure':
        return Color(0xFF8B0000); // Dark red
      case 'alerte':
        return Color(0xFFFF4500); // Orange red
      case 'vigilance':
        return Color(0xFFFFD700); // Gold
      case 'info':
        return Color(0xFF4169E1); // Royal blue
      default:
        return Colors.grey;
    }
  }
}
