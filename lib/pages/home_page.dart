import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/zone.dart';
import '../widgets/zone_card.dart';
import 'alert_page.dart';
import 'profil_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiService = ApiService();
  late Future<List<Zone>> _zonesFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _zonesFuture = _apiService.getZones();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FloodMap'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _selectedIndex == 0 ? _buildZonesView() : (_selectedIndex == 1 ? AlertPage() : ProfilPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Zones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildZonesView() {
    return FutureBuilder<List<Zone>>(
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _zonesFuture = _apiService.getZones();
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
            child: Text('Aucune zone disponible'),
          );
        }

        final zones = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _zonesFuture = _apiService.getZones();
            });
            await _zonesFuture;
          },
          child: ListView(
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
          ),
        );
      },
    );
  }
}

class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage({required this.zone});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  final _apiService = ApiService();
  late Future _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _apiService.getAlertsByZone(widget.zone.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.zone.nomZone)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: widget.zone.getRiskColor().withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Niveau de risque',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.zone.getRiskColor(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.zone.niveauRisque.toUpperCase(),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('💧 Hauteur d\'eau: ${widget.zone.hauteurEauCm} cm'),
                      SizedBox(height: 8),
                      Text('📍 Latitude: ${widget.zone.latitude}'),
                      SizedBox(height: 8),
                      Text('📍 Longitude: ${widget.zone.longitude}'),
                      SizedBox(height: 8),
                      if (widget.zone.dernierReleve != null)
                        Text('🕐 Dernier relevé: ${widget.zone.dernierReleve}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (widget.zone.description != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(widget.zone.description!),
                  ],
                ),
              SizedBox(height: 24),
              Text(
                'Alertes récentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              FutureBuilder(
                future: _alertsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  }

                  final alertes = snapshot.data ?? [];
                  if (alertes.isEmpty) {
                    return Text('Aucune alerte');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: alertes.length,
                    itemBuilder: (context, index) {
                      final alerte = alertes[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    alerte.niveau.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: alerte.getNiveauColor(),
                                    ),
                                  ),
                                  Text(
                                    alerte.dateAlerte,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(alerte.message),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
