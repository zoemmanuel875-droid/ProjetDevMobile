import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zone.dart';
import '../models/alert.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.4:3000/api';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // AUTH
  Future<Map<String, dynamic>> register(String nom, String email, String motDePasse, String telephone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nom,
          'email': email,
          'mot_de_passe': motDePasse,
          'telephone': telephone,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Erreur inscription: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'mot_de_passe': motDePasse,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Erreur connexion: $e');
    }
  }

  // ZONES
  Future<List<Zone>> getZones() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/zones'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((z) => Zone.fromJson(z)).toList();
      } else {
        throw Exception('Erreur chargement zones');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Zone> getZoneById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/zones/$id'));
      
      if (response.statusCode == 200) {
        return Zone.fromJson(json.decode(response.body));
      } else {
        throw Exception('Zone non trouvée');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ALERTES
  Future<List<Alert>> getAlertsByZone(int zoneId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alertes/zone/$zoneId'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((a) => Alert.fromJson(a)).toList();
      } else {
        throw Exception('Erreur chargement alertes');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<Alert>> getAllAlerts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alertes'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((a) => Alert.fromJson(a)).toList();
      } else {
        throw Exception('Erreur chargement alertes');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Alert> createAlert(int zoneId, String message, String niveau) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/alertes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'zone_id': zoneId,
          'message': message,
          'niveau': niveau,
        }),
      );

      if (response.statusCode == 201) {
        return Alert.fromJson(json.decode(response.body));
      } else {
        throw Exception(json.decode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Erreur création alerte: $e');
    }
  }

  Future<void> markAlertAsRead(int alertId) async {
    try {
      final token = await getToken();
      await http.put(
        Uri.parse('$baseUrl/alertes/$alertId/lue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Erreur marquage alerte: $e');
    }
  }

  // FAVORIS
  Future<void> addFavorite(int zoneId) async {
    try {
      final token = await getToken();
      await http.post(
        Uri.parse('$baseUrl/zones/$zoneId/favoris'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      throw Exception('Erreur ajout favori: $e');
    }
  }

  Future<void> removeFavorite(int zoneId) async {
    try {
      final token = await getToken();
      await http.delete(
        Uri.parse('$baseUrl/zones/$zoneId/favoris'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      throw Exception('Erreur suppression favori: $e');
    }
  }
}