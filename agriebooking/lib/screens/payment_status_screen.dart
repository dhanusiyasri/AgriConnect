import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(color: AppTheme.green100, shape: BoxShape.circle),
                child: const Icon(LucideIcons.checkCircle2, color: AppTheme.green600, size: 64),
              ),
              const SizedBox(height: 32),
              const Text('Payment Successful', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
              const SizedBox(height: 8),
              Text(
                'Your booking for ${equipment?.name ?? 'equipment'} has been confirmed.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.slate500),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('tracking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Track My Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.slate100,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
