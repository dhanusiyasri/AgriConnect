import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;
    if (equipment == null) return const SizedBox.shrink();

    final int price = state.bookingType == 'hourly' ? equipment.pricePerHour : equipment.pricePerDay;
    final int serviceFee = 150;
    final int expressFee = state.isExpressBooking ? 200 : 0;
    final int total = price + serviceFee + expressFee;
    
    final int payAmount = state.paymentOption == 'full' ? total : (total * 0.2).round();

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(color: AppTheme.slate100, shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate900, size: 20),
                                onPressed: () => context.read<AppState>().setScreen('damage-agreement'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.green50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.green100)),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: AppTheme.green700, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.green700, letterSpacing: 1.5)),
                                  Text('₹$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Option', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context.read<AppState>().setPaymentOption('full'),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: state.paymentOption == 'full' ? AppTheme.green50 : AppTheme.slate50,
                                          border: Border.all(color: state.paymentOption == 'full' ? AppTheme.green600 : AppTheme.slate100, width: 2),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Text('Full Payment', style: TextStyle(fontWeight: FontWeight.bold, color: state.paymentOption == 'full' ? AppTheme.green700 : AppTheme.slate600)),
                                            const SizedBox(height: 4),
                                            const Text('Pay 100% now', style: TextStyle(fontSize: 10, color: AppTheme.slate400)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context.read<AppState>().setPaymentOption('partial'),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: state.paymentOption == 'partial' ? AppTheme.green50 : AppTheme.slate50,
                                          border: Border.all(color: state.paymentOption == 'partial' ? AppTheme.green600 : AppTheme.slate100, width: 2),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Text('Partial Payment', style: TextStyle(fontWeight: FontWeight.bold, color: state.paymentOption == 'partial' ? AppTheme.green700 : AppTheme.slate600)),
                                            const SizedBox(height: 4),
                                            const Text('Pay 20% now', style: TextStyle(fontSize: 10, color: AppTheme.slate400)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                              const SizedBox(height: 16),
                              _buildPaymentMethod(context, state, 'UPI', 'UPI (GPay, PhonePe)', LucideIcons.zap),
                              const SizedBox(height: 12),
                              _buildPaymentMethod(context, state, 'Card', 'Credit / Debit Card', LucideIcons.creditCard),
                              const SizedBox(height: 12),
                              _buildPaymentMethod(context, state, 'NetBanking', 'Net Banking', LucideIcons.globe),
                            ],
                          ),
                        ),
                      ],
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
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.slate100))),
                child: ElevatedButton(
                  onPressed: () {
                    final booking = Booking(
                      id: 'BK-${1000 + (state.bookings.length * 7) % 9000}',
                      equipmentId: equipment.id,
                      equipmentName: equipment.name,
                      status: 'REQUESTED',
                      startTime: state.bookingType == 'hourly' ? (state.selectedSlot ?? '09:00 AM') : '06:00 AM',
                      endTime: state.bookingType == 'hourly' ? '05:00 PM' : '06:00 PM',
                      date: 'Oct 26, 2023',
                      amount: payAmount,
                      village: equipment.village,
                      ownerName: equipment.owner.name,
                      image: equipment.image,
                    );
                    context.read<AppState>().addBooking(booking);
                    context.read<AppState>().setScreen('payment-status');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: Text('Pay ₹$payAmount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, AppState state, String id, String name, IconData icon) {
    bool isSelected = state.paymentMethod == id;
    return GestureDetector(
      onTap: () => context.read<AppState>().setPaymentMethod(id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.green50 : AppTheme.slate50,
          border: Border.all(color: isSelected ? AppTheme.green600 : AppTheme.slate100, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: isSelected ? AppTheme.green700 : Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: isSelected ? Colors.white : AppTheme.slate400, size: 18),
                ),
                const SizedBox(width: 12),
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.slate900 : AppTheme.slate500)),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.green600 : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.green600 : AppTheme.slate300, width: 2),
              ),
              child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
            ),
          ],
        ),
      ),
    );
  }
}
