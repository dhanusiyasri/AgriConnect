import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Booking booking;

  const LiveTrackingScreen({super.key, required this.booking});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late LatLng _currentPos;
  late final RealtimeChannel _channel;

  Future<void> _fetchInitialLocation() async {
    try {
      final res = await Supabase.instance.client
          .from('tracking')
          .select('current_lat, current_lng')
          .eq('booking_id', widget.booking.id)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _currentPos = LatLng(
            (res['current_lat'] as num).toDouble(),
            (res['current_lng'] as num).toDouble(),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching initial location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPos = LatLng(widget.booking.lat ?? 30.9010, widget.booking.lng ?? 75.8573);
    _fetchInitialLocation();

    _channel = Supabase.instance.client
        .channel('public:tracking:owner:booking_id=eq.${widget.booking.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tracking',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: widget.booking.id,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (mounted) {
              setState(() {
                final lat = (newRecord['current_lat'] as num? ?? _currentPos.latitude).toDouble();
                final lng = (newRecord['current_lng'] as num? ?? _currentPos.longitude).toDouble();
                _currentPos = LatLng(lat, lng);
              });
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.booking.id}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentPos,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.owner_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPos,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            widget.booking.equipmentName.split(' ')[0],
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.agriculture, color: Color(0xFF2F7F33), size: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F7F33).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.gauge, color: Color(0xFF2F7F33)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Speed', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('15.4 km/h', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Signal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Row(
                            children: [
                              Icon(Icons.signal_cellular_alt, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Strong', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Engine', 'Online', Colors.green),
                      _buildMiniStat('Fuel', '84%', Colors.orange),
                      _buildMiniStat('Area Covered', '2.4 ha', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }
}
