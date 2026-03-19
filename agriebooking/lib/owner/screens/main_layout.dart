import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart';
import 'dashboard_screen.dart';
import 'machinery_screen.dart';
import 'bookings_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<Widget> _screens = const [
    DashboardScreen(),
    MachineryScreen(),
    BookingsScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mainState = context.watch<AppState>();
    final navIndex = context.watch<AppStateProvider>().navigationIndex;

    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: navIndex,
          onTap: (index) {
            context.read<AppStateProvider>().setNavigationIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2F7F33),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.home),
              label: mainState.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.agriculture),
              label: mainState.translate('machinery'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.calendar),
              label: mainState.translate('bookings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.barChart3),
              label: mainState.translate('analytics'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(LucideIcons.user),
              label: mainState.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}

