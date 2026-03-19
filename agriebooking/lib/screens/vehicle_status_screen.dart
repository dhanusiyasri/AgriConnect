import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class VehicleStatusScreen extends StatelessWidget {
  const VehicleStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;
    if (equipment == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rental Completion', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => state.setScreen('dashboard'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.green700,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                   const Icon(LucideIcons.checkCircle, color: Colors.white, size: 48),
                   const SizedBox(width: 20),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Rental Confirmed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                         Text('Booking ID: #${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Vehicle Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Equipment', equipment.name),
            _buildDetailRow(context, 'Type', equipment.type),
            _buildDetailRow(context, 'Owner', equipment.owner.name),
            _buildDetailRow(context, 'Date', 'Oct 26, 2023'),
            _buildDetailRow(context, 'Duration', state.bookingType == 'hourly' ? '4 Hours' : '1 Day'),
            _buildDetailRow(context, 'Driver Included', state.withDriver ? 'Yes' : 'No'),
            
            const SizedBox(height: 32),
            Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Base Rental', '₹${state.bookingType == 'hourly' ? equipment.pricePerHour * 4 : equipment.pricePerDay}'),
            if (state.withDriver) _buildDetailRow(context, 'Driver Fee', state.bookingType == 'hourly' ? '₹800' : '₹1500'),
            _buildDetailRow(context, 'Total Amount', '₹4500', isTotal: true),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => state.setScreen('dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green700,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Theme.of(context).textTheme.bodyLarge?.color : AppTheme.slate500, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold, color: isTotal ? AppTheme.green700 : Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}
