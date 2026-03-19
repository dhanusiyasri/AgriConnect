import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking.dart' as owner_booking;
import '../models/request.dart';
import 'live_tracking_screen.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import 'package:provider/provider.dart';
import 'report_issue_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final FarmerRequest request;

  const BookingDetailsScreen({super.key, required this.request});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isCompleted = false;

  final List<Map<String, String>> _activityLogs = [
    {'time': '08:00 AM', 'event': 'Machine deployed to field', 'status': 'done'},
    {'time': '09:30 AM', 'event': 'Plowing started in Sector 4', 'status': 'done'},
    {'time': '11:45 AM', 'event': 'Fuel refilled (20L)', 'status': 'done'},
  ];

  void _showCompletionConfirmation() {
    final mainState = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCircle, color: Color(0xFF2F7F33), size: 48),
            const SizedBox(height: 16),
            Text(
              mainState.translate('confirmReturn'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mainState.translate('confirmCondition'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportVehicleIssueScreen(vehicleName: widget.request.equipmentName),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(mainState.translate('reportIssue'), style: const TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AppStateProvider>().updateRequestStatus(widget.request.id, 'completed');
                      setState(() {
                        _isCompleted = true;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mainState.translate('bookingCompleted'))),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7F33),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(mainState.translate('confirm'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+919876543210'); // Mock number
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendSMS() async {
    final Uri launchUri = Uri(scheme: 'sms', path: '+919876543210');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mainState.translate('bookingDetails')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Info Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2F7F33).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2F7F33).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.request.farmerAvatar ?? 'https://i.pravatar.cc/150?u=${widget.request.farmerName}'),
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.request.farmerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(widget.request.farmerType, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _makeCall,
                          icon: const Icon(LucideIcons.phone, size: 18, color: Colors.white),
                          label: Text(mainState.translate('call'), style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F7F33),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _sendSMS,
                          icon: const Icon(LucideIcons.messageSquare, size: 18, color: Color(0xFF2F7F33)),
                          label: Text(mainState.translate('message'), style: const TextStyle(color: Color(0xFF2F7F33))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2F7F33)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Booking Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(mainState.translate('durationLabel'), widget.request.duration, LucideIcons.clock),
                  _buildStatCard(mainState.translate('totalFare'), '₹${widget.request.breakdown?.total ?? 0}', LucideIcons.banknote),
                  _buildStatCard(mainState.translate('distance'), widget.request.distance, LucideIcons.mapPin),
                  _buildStatCard(mainState.translate('status'), mainState.translate(widget.request.status?.toLowerCase() ?? 'pending'), LucideIcons.activity),
                ],
              ),
            ),

            if ((widget.request.status?.toLowerCase() == 'active' || widget.request.status?.toLowerCase() == 'accepted') && !_isCompleted)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: [
                    Consumer<AppStateProvider>(
                      builder: (context, provider, _) {
                        final isBroadcasting = provider.isBroadcasting(widget.request.id);
                        return Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (isBroadcasting) {
                                  provider.stopLocationBroadcasting();
                                } else {
                                  provider.startLocationBroadcasting(widget.request.id, widget.request.equipmentId);
                                }
                              },
                              icon: Icon(
                                isBroadcasting ? LucideIcons.stopCircle : LucideIcons.playCircle,
                                color: Colors.white,
                              ),
                              label: Text(
                                isBroadcasting ? mainState.translate('stopTrip') : mainState.translate('startTrip'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBroadcasting ? Colors.red : const Color(0xFF2F7F33),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final trackingBooking = owner_booking.Booking(
                          id: widget.request.id,
                          equipmentName: widget.request.equipmentName,
                          equipmentId: widget.request.equipmentId,
                          farmerName: widget.request.farmerName,
                          farmerAvatar: widget.request.farmerAvatar,
                          date: '', 
                          timeSlot: widget.request.duration,
                          location: widget.request.location,
                          status: widget.request.status ?? 'active',
                          lat: 30.9010, // Mock
                          lng: 75.8573, // Mock
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveTrackingScreen(booking: trackingBooking),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.navigation, color: Colors.white, size: 18),
                      label: Text(mainState.translate('liveTrack'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showCompletionConfirmation,
                      icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
                      label: Text(mainState.translate('markAsCompleted'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7F33),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                  ],
                ),
              ),
            
            if (widget.request.status?.toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AppStateProvider>().updateRequestStatus(widget.request.id, 'REJECTED');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(mainState.translate('reject'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AppStateProvider>().updateRequestStatus(widget.request.id, 'ACCEPTED');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F7F33),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(mainState.translate('accept'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Activity Log
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(mainState.translate('liveActivityLog'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activityLogs.length,
              itemBuilder: (context, index) {
                final log = _activityLogs[index];
                final isLast = index == _activityLogs.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(color: Color(0xFF2F7F33), shape: BoxShape.circle),
                        ),
                        if (!isLast)
                          Container(width: 2, height: 40, color: const Color(0xFF2F7F33).withOpacity(0.2)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log['time']!, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(log['event']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Emergency / Issues
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report an Issue', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                          Text('Vehicle damage or operator dispute', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportVehicleIssueScreen(vehicleName: widget.request.equipmentName),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(mainState.translate('report'), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2F7F33)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
