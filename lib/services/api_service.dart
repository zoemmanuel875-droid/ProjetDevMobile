import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zone.dart';
import '../models/alert.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.4:3000/api';
  static const Duration timeout = Duration(seconds: 30);
  
  // Client HTTP persistant avec timeout
  static final http.Client _client = http.Client();
  
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
      print('🔐 Tentative d\'inscription vers: $baseUrl/auth/register');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nom,
          'email': email,
          'mot_de_passe': motDePasse,
          'telephone': telephone,
        }),
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Connexion au serveur timeout (${timeout.inSeconds}s)');
        },
      );

      print('✅ Réponse reçue: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur inscription');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Erreur timeout: $e');
      throw Exception('❌ Serveur inaccessible (timeout). Vérifiez que le serveur Node.js tourne sur port 3000');
    } catch (e) {
      print('❌ Erreur inscription: $e');
      throw Exception('Erreur inscription: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    try {
      print('🔐 Tentative de connexion vers: $baseUrl/auth/login');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'mot_de_passe': motDePasse,
        }),
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Connexion au serveur timeout (${timeout.inSeconds}s)');
        },
      );

      print('✅ Réponse reçue: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Identifiants incorrects');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Erreur timeout: $e');
      throw Exception('❌ Serveur inaccessible (timeout). Vérifiez que le serveur Node.js tourne sur port 3000');
    } catch (e) {
      print('❌ Erreur connexion: $e');
      throw Exception('Erreur connexion: $e');
    }
  }

  // ZONES
  Future<List<Zone>> getZones() async {
    try {
      print('📍 Chargement des zones depuis: $baseUrl/zones');
      
      final response = await _client.get(Uri.parse('$baseUrl/zones')).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout lors du chargement des zones');
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ ${data.length} zones chargées');
        return data.map((z) => Zone.fromJson(z)).toList();
      } else {
        throw Exception('Erreur chargement zones (${response.statusCode})');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      throw Exception('Serveur inaccessible - Timeout');
    } catch (e) {
      print('❌ Erreur zones: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<Zone> getZoneById(int id) async {
    try {
      print('📍 Chargement de la zone $id');
      
      final response = await _client.get(Uri.parse('$baseUrl/zones/$id')).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout lors du chargement de la zone');
        },
      );
      
      if (response.statusCode == 200) {
        return Zone.fromJson(json.decode(response.body));
      } else {
        throw Exception('Zone non trouvée');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      throw Exception('Serveur inaccessible - Timeout');
    } catch (e) {
      print('❌ Erreur zone: $e');
      throw Exception('Erreur: $e');
    }
  }

  // ALERTES
  Future<List<Alert>> getAlertsByZone(int zoneId) async {
    try {
      print('🔔 Chargement des alertes pour la zone $zoneId');
      
      final response = await _client.get(Uri.parse('$baseUrl/alertes/zone/$zoneId')).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout lors du chargement des alertes');
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ ${data.length} alertes chargées');
        return data.map((a) => Alert.fromJson(a)).toList();
      } else {
        throw Exception('Erreur chargement alertes');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      throw Exception('Serveur inaccessible - Timeout');
    } catch (e) {
      print('❌ Erreur alertes: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<List<Alert>> getAllAlerts() async {
    try {
      print('🔔 Chargement de toutes les alertes');
      
      final response = await _client.get(Uri.parse('$baseUrl/alertes')).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout lors du chargement des alertes');
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ ${data.length} alertes chargées');
        return data.map((a) => Alert.fromJson(a)).toList();
      } else {
        throw Exception('Erreur chargement alertes');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      throw Exception('Serveur inaccessible - Timeout');
    } catch (e) {
      print('❌ Erreur alertes: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<Alert> createAlert(int zoneId, String message, String niveau) async {
    try {
      final token = await getToken();
      print('📢 Création d\'une alerte');
      
      final response = await _client.post(
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
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout lors de la création de l\'alerte');
        },
      );

      if (response.statusCode == 201) {
        print('✅ Alerte créée');
        return Alert.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Erreur création alerte');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      throw Exception('Serveur inaccessible - Timeout');
    } catch (e) {
      print('❌ Erreur création alerte: $e');
      throw Exception('Erreur création alerte: $e');
    }
  }

  Future<void> markAlertAsRead(int alertId) async {
    try {
      final token = await getToken();
      print('✅ Marquage alerte $alertId comme lue');
      
      await _client.put(
        Uri.parse('$baseUrl/alertes/$alertId/lue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout');
        },
      );
    } catch (e) {
      print('❌ Erreur marquage alerte: $e');
    }
  }

  // FAVORIS
  Future<void> addFavorite(int zoneId) async {
    try {
      final token = await getToken();
      print('⭐ Ajout de la zone $zoneId aux favoris');
      
      await _client.post(
        Uri.parse('$baseUrl/zones/$zoneId/favoris'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout');
        },
      );
      print('✅ Favori ajouté');
    } catch (e) {
      print('❌ Erreur ajout favori: $e');
      throw Exception('Erreur ajout favori: $e');
    }
  }

  Future<void> removeFavorite(int zoneId) async {
    try {
      final token = await getToken();
      print('🗑️ Suppression de la zone $zoneId des favoris');
      
      await _client.delete(
        Uri.parse('$baseUrl/zones/$zoneId/favoris'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException('Timeout');
        },
      );
      print('✅ Favori supprimé');
    } catch (e) {
      print('❌ Erreur suppression favori: $e');
      throw Exception('Erreur suppression favori: $e');
    }
  }
}