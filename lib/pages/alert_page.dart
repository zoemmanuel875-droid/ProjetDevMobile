import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/alert.dart';

class AlertPage extends StatefulWidget {
  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final _apiService = ApiService();
  late Future<List<Alert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _apiService.getAllAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Alert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _alertsFuture = _apiService.getAllAlerts();
                      });
                    },
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'Aucune alerte',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final alertes = snapshot.data!;
          
          // Grouper par niveau
          final groupedAlerts = <String, List<Alert>>{};
          for (var alert in alertes) {
            if (!groupedAlerts.containsKey(alert.niveau)) {
              groupedAlerts[alert.niveau] = [];
            }
            groupedAlerts[alert.niveau]!.add(alert);
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _alertsFuture = _apiService.getAllAlerts();
              });
              await _alertsFuture;
            },
            child: ListView(
              children: groupedAlerts.entries.map((entry) {
                final niveau = entry.key;
                final alerts = entry.value;

                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          niveau.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: alerts.isNotEmpty ? alerts[0].getNiveauColor() : Colors.grey,
                          ),
                        ),
                      ),
                      ...alerts.map((alert) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: alert.getNiveauColor(),
                              child: Icon(Icons.warning, color: Colors.white),
                            ),
                            title: Text(
                              alert.nomZone ?? 'Zone inconnue',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              alert.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              alert.dateAlerte.split(' ')[0],
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Zone: ${alert.nomZone}'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Message:'),
                                        SizedBox(height: 8),
                                        Text(alert.message),
                                        SizedBox(height: 16),
                                        Text('Niveau: ${alert.niveau}'),
                                        SizedBox(height: 8),
                                        Text('Date: ${alert.dateAlerte}'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Fermer'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
