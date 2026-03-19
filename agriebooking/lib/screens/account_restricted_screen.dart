import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AccountRestrictedScreen extends StatelessWidget {
  const AccountRestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                decoration: const BoxDecoration(color: AppTheme.red50, shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertTriangle, color: AppTheme.red600, size: 64),
              ),
              const SizedBox(height: 32),
              const Text('Account Restricted', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
              const SizedBox(height: 16),
              const Text(
                'Your account has been temporarily restricted due to multiple unpaid damage reports.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.slate500, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppTheme.slate50, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate200)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Pending Dues', style: TextStyle(fontSize: 16, color: AppTheme.slate500)),
                        Text('₹12,450', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.red600)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.slate200),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(LucideIcons.info, color: AppTheme.slate400, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('Clear dues to restore account access', style: TextStyle(fontSize: 12, color: AppTheme.slate500))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.slate700,
                    elevation: 0,
                    side: const BorderSide(color: AppTheme.slate200),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.read<AppState>().setScreen('language'),
                child: const Text('Log Out', style: TextStyle(color: AppTheme.red600, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
