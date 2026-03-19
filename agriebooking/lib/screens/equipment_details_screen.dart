import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class EquipmentDetailsScreen extends StatelessWidget {
  const EquipmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;
    if (equipment == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      equipment.image,
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 320,
                        width: double.infinity,
                        color: AppTheme.green700,
                        child: const Icon(Icons.agriculture, color: Colors.white, size: 64),
                      ),
                    ),
                    Positioned(
                      top: 48,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.9), shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
                              onPressed: () => context.read<AppState>().setScreen('dashboard'),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.9), shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(LucideIcons.share2, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    equipment.type.toUpperCase(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.green700, letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(equipment.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppTheme.green50, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.star, color: AppTheme.green700, size: 16),
                                  const SizedBox(width: 4),
                                  Text(equipment.rating.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.green700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<AppState>().setBookingType('hourly'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: state.bookingType == 'hourly' ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                    border: Border.all(color: state.bookingType == 'hourly' ? Theme.of(context).primaryColor : AppTheme.slate100, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(state.translate('pricePerHour').split(' ').last, style: TextStyle(fontSize: 12, color: state.bookingType == 'hourly' ? Theme.of(context).primaryColor : AppTheme.slate400)),
                                      const SizedBox(height: 4),
                                      Text('₹${equipment.pricePerHour}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: state.bookingType == 'hourly' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<AppState>().setBookingType('daily'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: state.bookingType == 'daily' ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                    border: Border.all(color: state.bookingType == 'daily' ? Theme.of(context).primaryColor : AppTheme.slate100, width: 2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(state.translate('fullDay'), style: TextStyle(fontSize: 12, color: state.bookingType == 'daily' ? Theme.of(context).primaryColor : AppTheme.slate400)),
                                      const SizedBox(height: 4),
                                      Text('₹${equipment.pricePerDay}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: state.bookingType == 'daily' ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(state.translate('description'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleLarge?.color)),
                        const SizedBox(height: 12),
                        Text(
                          'High-performance tractor suitable for all types of soil conditions. Equipped with modern features and fuel-efficient engine. Perfect for land preparation and heavy-duty farming tasks.',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.translate('ownerInfo'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.titleLarge?.color)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network('https://picsum.photos/seed/owner2/100/100', width: 48, height: 48, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(equipment.owner.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                          Text('${equipment.owner.experience} ${state.translate('experience')}', style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => state.launchPhone('+919876543210'),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle, border: Border.all(color: AppTheme.slate100)),
                                          child: Icon(LucideIcons.phone, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => context.read<AppState>().setScreen('support'),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle, border: Border.all(color: AppTheme.slate100)),
                                          child: Icon(LucideIcons.headphones, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: const Border(top: BorderSide(color: AppTheme.slate100))),
              child: ElevatedButton(
                onPressed: () => context.read<AppState>().setScreen('booking-details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green700,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppTheme.green200,
                ),
                child: Text(
                  '${state.translate('bookNow')} (₹${state.bookingType == 'hourly' ? equipment.pricePerHour : equipment.pricePerDay})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
