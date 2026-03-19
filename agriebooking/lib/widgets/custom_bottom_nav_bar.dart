import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String activeScreen;

  const CustomBottomNavBar({super.key, required this.activeScreen});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.slate100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.home, context.read<AppState>().translate('home'), 'dashboard', activeScreen == 'dashboard'),
            _buildNavItem(context, LucideIcons.calendar, context.read<AppState>().translate('bookings'), 'bookings', activeScreen == 'bookings'),
            _buildNavItem(context, LucideIcons.helpCircle, context.read<AppState>().translate('support'), 'support', activeScreen == 'support' || activeScreen == 'ai-advisor'),
            _buildNavItem(context, LucideIcons.user, context.read<AppState>().translate('profile'), 'profile', activeScreen == 'profile' || activeScreen == 'settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String screen, bool isActive) {
    return GestureDetector(
      onTap: () => context.read<AppState>().setScreen(screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.green700 : AppTheme.slate400, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.green700 : AppTheme.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
