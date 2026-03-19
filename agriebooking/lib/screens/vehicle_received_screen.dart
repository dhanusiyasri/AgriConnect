import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class VehicleReceivedScreen extends StatelessWidget {
  const VehicleReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate900),
                    onPressed: () => context.read<AppState>().setScreen('bookings'),
                  ),
                  const SizedBox(width: 8),
                  const Text('Vehicle Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.amber400.withOpacity(0.1), border: Border.all(color: AppTheme.amber400.withOpacity(0.3)), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: AppTheme.orange600, size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Important Notice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.orange600)),
                                const SizedBox(height: 4),
                                Text(
                                  'Please ensure the vehicle is returned in the same condition. Any damages reported will incur additional fees.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.orange600.withOpacity(0.8), height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100), boxShadow: [BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))]),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(color: AppTheme.green50, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.checkCircle2, color: AppTheme.green600, size: 40),
                          ),
                          const SizedBox(height: 24),
                          const Text('Vehicle Received', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                          const SizedBox(height: 8),
                          const Text('You have successfully received the vehicle. Your rental period has started.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.slate500)),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                const Text('ACTIVE USAGE TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                Text(
                                  '${(state.usageTime ~/ 3600).toString().padLeft(2, '0')}:${((state.usageTime % 3600) ~/ 60).toString().padLeft(2, '0')}:${(state.usageTime % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppTheme.slate900),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(LucideIcons.clock, size: 14, color: AppTheme.slate500),
                                    SizedBox(width: 4),
                                    Text('Started at 09:00 AM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<AppState>().setScreen('contact-owner'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.slate700,
                              elevation: 0,
                              side: const BorderSide(color: AppTheme.slate200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.messageSquare, size: 18),
                                SizedBox(width: 8),
                                Text('Contact Owner', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<AppState>().setScreen('damage-report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.red50,
                              foregroundColor: AppTheme.red600,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.alertCircle, size: 18),
                                SizedBox(width: 8),
                                Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: const Text('Complete Rental', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
