import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import '../models/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'booking_details_screen.dart';
import 'add_vehicle_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Equipment equipment;

  const VehicleDetailsScreen({super.key, required this.equipment});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _logController = TextEditingController();
  final List<String> _maintenanceLogs = [
    'Oct 12, 2023: Engine oil changed.',
    'Sep 20, 2023: Tires rotated and pressure checked.',
    'Aug 15, 2023: Routine hydraulics inspection.',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _logController.dispose();
    super.dispose();
  }

  void _addLog() {
    if (_logController.text.isEmpty) return;
    setState(() {
      _maintenanceLogs.insert(0, '${_formatDate(context.read<AppState>(), DateTime.now())}: ${_logController.text}');
      _logController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AppState>().translate('updateLog'))));
  }

  String _formatDate(AppState state, DateTime date) {
    return '${_getMonth(state, date.month)} ${date.day}, ${date.year}';
  }

  String _getMonth(AppState state, int month) {
    const monthKeys = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return state.translate(monthKeys[month - 1]);
  }

  @override
  Widget build(BuildContext context) {
    // Filter bookings for this vehicle
    final allRequests = context.watch<AppStateProvider>().requests;
    final mainState = context.watch<AppState>();
    final vehicleRequests = allRequests.where((r) => r.equipmentName == widget.equipment.name).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.equipment.image.startsWith('http')
                ? Image.network(widget.equipment.image, fit: BoxFit.cover)
                : Image.file(File(widget.equipment.image), fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.edit3),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddVehicleScreen(equipment: widget.equipment)),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.equipment.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.equipment.model, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.equipment.status == 'available' ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mainState.translate(widget.equipment.status.toLowerCase()),
                          style: TextStyle(color: widget.equipment.status == 'available' ? Colors.green[800] : Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildInfoItem(LucideIcons.gauge, '${widget.equipment.fuelLevel ?? 0}%', mainState.translate('fuel'))),
                        Expanded(child: _buildInfoItem(LucideIcons.mapPin, '2.5 km', mainState.translate('distance'))),
                        Expanded(child: _buildInfoItem(LucideIcons.wrench, widget.equipment.nextService ?? 'N/A', mainState.translate('service'))),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2F7F33),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2F7F33),
                tabs: [
                  Tab(text: mainState.translate('bookingsTitle')),
                  Tab(text: mainState.translate('maintenance')),
                  Tab(text: mainState.translate('availability')),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsTab(vehicleRequests, mainState),
            _buildMaintenanceTab(mainState),
            _buildAvailabilityTab(mainState),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF2F7F33), size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 1),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
      ],
    );
  }

  Widget _buildBookingsTab(List<FarmerRequest> requests, AppState mainState) {
    if (requests.isEmpty) {
      return Center(child: Text(mainState.translate('noBookingsFound')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 0,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(request.farmerAvatar ?? 'https://i.pravatar.cc/150?u=${request.farmerName}'),
              radius: 24,
            ),
            title: Text(request.farmerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(request.duration),
                const SizedBox(height: 4),
                Text(request.location, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            trailing: const Icon(LucideIcons.chevronRight, size: 20),
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingDetailsScreen(request: request)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceTab(AppState mainState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mainState.translate('updateLog'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          TextField(
            controller: _logController,
            decoration: InputDecoration(
              hintText: mainState.translate('describeMaintenance'),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.plusCircle, color: Color(0xFF2F7F33)),
                onPressed: _addLog,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Text(mainState.translate('history'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          ..._maintenanceLogs.map((log) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(log, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTab(AppState mainState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: widget.equipment.status == 'available' ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.equipment.status == 'available' ? Colors.green.shade200 : Colors.orange.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainState.translate('currentStatus'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      widget.equipment.status == 'available' ? mainState.translate('availableRent') : mainState.translate('currentlyUnavail'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.equipment.status == 'available' ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: widget.equipment.status == 'available',
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    final newStatus = value ? 'available' : 'unavailable';
                    
                    final updatedVehicle = widget.equipment.copyWith(status: newStatus);
                    
                    // Update globally
                    context.read<AppStateProvider>().updateVehicle(updatedVehicle);
                    
                    // Go back to machinery list so it refreshes cleanly with new state
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(mainState.translate('machineryStatusUpdate').replaceFirst('{status}', mainState.translate(newStatus)))),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mainState.translate('availableSlots'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton.icon(
                icon: const Icon(LucideIcons.edit2, size: 14),
                label: Text(mainState.translate('edit')),
                onPressed: () => _showEditSlotsDialog(mainState),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2F7F33)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.equipment.availableSlots.map((slot) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2F7F33).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2F7F33).withOpacity(0.2)),
              ),
              child: Text(slot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2F7F33))),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text(mainState.translate('blockDates'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          if (widget.equipment.blockedDates.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.equipment.blockedDates.map((date) => Chip(
                label: Text(_formatDate(mainState, date), style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => _removeBlockedDate(date),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: () => _selectBlockedDate(mainState),
            icon: const Icon(LucideIcons.calendar),
            label: Text(mainState.translate('selectDatesToBlock')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(AppState mainState) {
    final Map<String, String> tempSchedule = Map.from(widget.equipment.weeklySchedule);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(mainState.translate('editSchedule')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: tempSchedule.keys.map((day) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(mainState.translate(day.toLowerCase()))),
                    Expanded(
                      flex: 3,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: tempSchedule[day],
                        items: [
                          '08:00 AM - 06:00 PM',
                          '09:00 AM - 05:00 PM',
                          '08:00 AM - 01:00 PM',
                          '01:00 PM - 06:00 PM',
                          'Closed'
                        ].map((time) => DropdownMenuItem(value: time, child: Text(time, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempSchedule[day] = val);
                        },
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(mainState.translate('cancel'))),
            TextButton(
              onPressed: () {
                final updated = widget.equipment.copyWith(weeklySchedule: tempSchedule);
                context.read<AppStateProvider>().updateVehicle(updated);
                Navigator.pop(context);
                Navigator.pop(context); // Refresh by going back
              }, 
              child: Text(mainState.translate('save'))
            ),
          ],
        ),
      ),
    );
  }

  void _selectBlockedDate(AppState mainState) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && !widget.equipment.blockedDates.contains(pickedDate)) {
      final newBlocked = List<DateTime>.from(widget.equipment.blockedDates)..add(pickedDate);
      final updated = widget.equipment.copyWith(blockedDates: newBlocked);
      context.read<AppStateProvider>().updateVehicle(updated);
      Navigator.pop(context); // Refresh
    }
  }

  void _removeBlockedDate(DateTime date) {
    final newBlocked = List<DateTime>.from(widget.equipment.blockedDates)..remove(date);
    final updated = widget.equipment.copyWith(blockedDates: newBlocked);
    context.read<AppStateProvider>().updateVehicle(updated);
    Navigator.pop(context); // Refresh
  }

  void _showEditSlotsDialog(AppState mainState) {
    final List<String> allSlots = [
      '06:00 - 09:00',
      '09:00 - 12:00',
      '12:00 - 15:00',
      '15:00 - 18:00',
      '18:00 - 21:00',
      '21:00 - 00:00',
      '00:00 - 03:00',
      '03:00 - 06:00'
    ];
    final List<String> tempSlots = List.from(widget.equipment.availableSlots);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(mainState.translate('availabilitySlots')), // Editable Vehicle Slots
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allSlots.map((slot) {
                final isSelected = tempSlots.contains(slot);
                return GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      if (isSelected) {
                        if (tempSlots.length > 1) tempSlots.remove(slot);
                      } else {
                        tempSlots.add(slot);
                        tempSlots.sort();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2F7F33) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? const Color(0xFF2F7F33) : Colors.grey.shade300),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(mainState.translate('cancel'))),
            TextButton(
              onPressed: () {
                final updated = widget.equipment.copyWith(availableSlots: tempSlots);
                context.read<AppStateProvider>().updateVehicle(updated);
                Navigator.pop(context);
                Navigator.pop(context); // Refresh
              }, 
              child: Text(mainState.translate('save'))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day, String time, bool isOpen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(time, style: TextStyle(color: isOpen ? Colors.black87 : Colors.red)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
