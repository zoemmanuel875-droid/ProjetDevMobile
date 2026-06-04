import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/zone.dart';
import '../widgets/zone_card.dart';
import 'home_page.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _apiService = ApiService();
  late Future<List<Zone>> _zonesFuture;

  @override
  void initState() {
    super.initState();
    _zonesFuture = _apiService.getZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zones inondables'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Zone>>(
        future: _zonesFuture,
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
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune zone'));
          }

          final zones = snapshot.data!;
          return ListView(
            children: zones.map((zone) {
              return ZoneCard(
                zone: zone,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoneDetailPage(zone: zone),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
