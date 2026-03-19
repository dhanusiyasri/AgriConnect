import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/booking.dart' as owner_booking;
import '../models/request.dart';
import 'live_tracking_screen.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import 'package:provider/provider.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _searchController = TextEditingController();
  List<FarmerRequest> _filteredBookings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      setState(() {
        // Safe casting the FarmerRequest logic into Bookings logic on UI
        // In full iteration, these should share a model.
      });
    });
  }

  void _filterBookings(String query) {
     // TODO: Implement real filtering via app_state_provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(context.watch<AppState>().translate('bookingsTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBookings,
              decoration: InputDecoration(
                hintText: context.read<AppState>().translate('searchByFarmer'),
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          // Update filtered list when provider changes
          _filteredBookings = _searchController.text.isEmpty 
              ? provider.requests 
              : provider.requests.where((r) => 
                  r.farmerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                  r.equipmentName.toLowerCase().contains(_searchController.text.toLowerCase())
                ).toList();

          if (_filteredBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.searchX, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(context.read<AppState>().translate('noBookingsFound'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = _filteredBookings[index];
              return _buildBookingCard(request);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(FarmerRequest request) {
    Color statusColor;
    switch (request.status?.toLowerCase()) {
      case 'active': statusColor = Colors.blue; break;
      case 'pending': statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingDetailsScreen(request: request)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(request.farmerAvatar ?? 'https://i.pravatar.cc/150?u=${request.farmerName}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              request.id, 
                              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                             child: Text(
                                context.read<AppState>().translate((request.status ?? 'PENDING').toLowerCase()),
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(request.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.agriculture, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.equipmentName, 
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.duration, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (request.status?.toLowerCase() == 'pending' || request.status?.toLowerCase() == 'requested')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AppStateProvider>().updateRequestStatus(request.id, 'REJECTED');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(context.read<AppState>().translate('decline')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AppStateProvider>().updateRequestStatus(request.id, 'ACCEPTED');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7F33),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(context.read<AppState>().translate('accept'), style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else if (request.status?.toLowerCase() == 'active' || request.status?.toLowerCase() == 'accepted')
              ElevatedButton.icon(
                onPressed: () {
                  // Map FarmerRequest to owner_booking.Booking for tracking
                  final trackingBooking = owner_booking.Booking(
                    id: request.id,
                    equipmentName: request.equipmentName,
                    equipmentId: request.equipmentId,
                    farmerName: request.farmerName,
                    farmerAvatar: request.farmerAvatar,
                    date: '', // Provide dummy or actual if available
                    timeSlot: request.duration,
                    location: request.location,
                    status: request.status ?? 'active',
                    lat: 30.9010, // Mock
                    lng: 75.8573, // Mock
                  );
                  // Since we are in the owner sub-folder, we need the correct import or just use a dynamic route if needed.
                  // But we can import the screen directly.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveTrackingScreen(booking: trackingBooking),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.navigation, size: 16, color: Colors.white),
                label: Text(context.read<AppState>().translate('liveTrack'), style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
