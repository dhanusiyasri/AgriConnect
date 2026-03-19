import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  double _tractorTop = 200;
  double _tractorLeft = 150;
  LatLng _currentPos = const LatLng(30.9010, 75.8573);
  late final RealtimeChannel _channel;


  Future<void> _fetchInitialLocation(String? bookingId) async {
    if (bookingId == null) return;
    try {
      final res = await Supabase.instance.client
          .from('tracking')
          .select('current_lat, current_lng')
          .eq('booking_id', bookingId)
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
    final state = context.read<AppState>();
    final bookingId = state.selectedBooking?.id;

    _fetchInitialLocation(bookingId);

    if (bookingId != null) {
      _channel = Supabase.instance.client
          .channel('public:tracking:booking_id=eq.$bookingId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'tracking',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'booking_id',
              value: bookingId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              if (mounted) {
                setState(() {
                  final lat = (newRecord['current_lat'] as num? ?? 30.9010).toDouble();
                  final lng = (newRecord['current_lng'] as num? ?? 75.8573).toDouble();
                  
                  // Update tractor position based on real coordinates
                  // We'll calculate the offset from the initial center for the mock markers for now, 
                  // or just update the marker point directly in the FlutterMap.
                  // Since we are using markers in FlutterMap now (from previous edit), 
                  // let's use actual lat/lng.
                  _currentPos = LatLng(lat, lng);
                });
              }
            },
          )
          .subscribe();
    }
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(state.translate('equipmentLocation'), style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => state.setScreen('bookings'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(30.9010, 75.8573), // Default or from booking
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.agri_connect',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPos,
                          width: 60,
                          height: 60,
                          child: const Icon(Icons.agriculture, size: 40, color: AppTheme.green700),
                        ),
                        const Marker(
                          point: LatLng(30.8950, 75.8500),
                          width: 40,
                          height: 40,
                          child: Icon(LucideIcons.mapPin, size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
                // Overlay for dark mode or glassmorphism if needed
                if (isDark)
                  IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network('https://picsum.photos/seed/truck/100/100', width: 48, height: 48, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.translate('driverOnWay'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            Text(state.translate('eta'), style: const TextStyle(fontSize: 12, color: AppTheme.slate500)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          context, 
                          LucideIcons.phone, 
                          AppTheme.green700,
                          () => state.launchPhone('+919876543210'),
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context, 
                          LucideIcons.messageCircle, 
                          Colors.blue,
                          () => state.launchSms('+919876543210'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatusItem(context, state.translate('accepted'), '10:30 AM', true),
                _buildStatusItem(context, state.translate('driverOnWay'), '10:45 AM (Current)', true, isCurrent: true),
                _buildStatusItem(context, state.translate('eta'), '11:00 AM', false),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatCard(context, state.translate('distanceLabel'), '3.2 km', LucideIcons.map),
                    const SizedBox(width: 16),
                    _buildStatCard(context, state.translate('arrivalLabel'), '15 min', LucideIcons.clock),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showExtensionDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.green700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(state.translate('extendBooking'), style: const TextStyle(color: AppTheme.green700, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => state.setScreen('vehicle-status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(state.translate('confirm'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExtensionDialog(BuildContext context) {
    final state = context.read<AppState>();
    int selectedHours = 1;
    int selectedMinutes = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(state.translate('extendBooking'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.translate('extendQuestion')),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(
                    state.translate('hoursLabel'), 
                    selectedHours, 
                    (val) => setDialogState(() => selectedHours = val),
                    12
                  ),
                  const SizedBox(width: 24),
                  _buildPicker(
                    state.translate('minutesLabel'), 
                    selectedMinutes, 
                    (val) => setDialogState(() => selectedMinutes = val),
                    59,
                    step: 15
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(state.translate('cancel'), style: const TextStyle(color: AppTheme.slate400)),
            ),
            ElevatedButton(
              onPressed: () {
                state.extendBooking(selectedHours, selectedMinutes);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.translate('bookingExtended').replaceAll('{hours}', selectedHours.toString()).replaceAll('{minutes}', selectedMinutes.toString())),
                    backgroundColor: AppTheme.green700,
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(state.translate('confirm')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(String label, int current, Function(int) onUpdate, int max, {int step = 1}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slate500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.slate100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  if (current >= step) onUpdate(current - step);
                },
              ),
              Text(
                current.toString().padLeft(2, '0'), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  if (current + step <= max) onUpdate(current + step);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.slate100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.green700, size: 20),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String title, String time, bool isDone, {bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCurrent ? AppTheme.green700 : (isDone ? AppTheme.green700 : AppTheme.slate300),
                  shape: BoxShape.circle,
                ),
              ),
              if (title != 'Expected Arrival')
                Container(
                  width: 2,
                  height: 30,
                  color: isDone ? AppTheme.green700 : AppTheme.slate200,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? AppTheme.green700 : (isDone ? Theme.of(context).textTheme.bodyLarge?.color : AppTheme.slate400),
                  ),
                ),
                Text(time, style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
