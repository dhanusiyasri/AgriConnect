import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class DamageAgreementScreen extends StatelessWidget {
  const DamageAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate900),
                  onPressed: () => context.read<AppState>().setScreen('booking-details'),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(color: AppTheme.orange50, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.shieldCheck, color: AppTheme.orange500, size: 48),
                    ),
                    const SizedBox(height: 32),
                    const Text('Damage Policy Agreement', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                    const SizedBox(height: 16),
                    const Text(
                      'By proceeding with this booking, you agree that you will be responsible for any damages caused to the machinery during the rental period.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.slate500, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(24)),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.slate900)),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Icon(LucideIcons.checkCircle2, color: AppTheme.green600, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text('Inspect vehicle before starting', style: TextStyle(fontSize: 14, color: AppTheme.slate500))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Icon(LucideIcons.checkCircle2, color: AppTheme.green600, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text('Report any existing damages', style: TextStyle(fontSize: 14, color: AppTheme.slate500))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Icon(LucideIcons.checkCircle2, color: AppTheme.green600, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text('Pay for repairs if damage occurs', style: TextStyle(fontSize: 14, color: AppTheme.slate500))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: const Text('I Agree & Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
