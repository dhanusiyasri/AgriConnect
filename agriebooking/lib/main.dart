import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';

import 'screens/splash_screen.dart';
import 'screens/language_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/equipment_details_screen.dart';
import 'screens/booking_details_screen.dart';
import 'screens/damage_agreement_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/payment_status_screen.dart';
import 'screens/vehicle_received_screen.dart';
import 'screens/review_screen.dart';
import 'screens/support_screen.dart';
import 'screens/vehicle_status_screen.dart';
import 'screens/ai_advisor_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/damage_report_screen.dart';
import 'screens/account_restricted_screen.dart';
import 'screens/contact_owner_screen.dart';
import 'screens/notification_screen.dart';

// Owner App Imports
import 'package:agriebooking/owner/providers/app_state_provider.dart' as owner_provider;
import 'package:agriebooking/owner/screens/main_layout.dart' as owner_screens;

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for consistent mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set immersive status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Supabase.initialize(
    url: 'https://wnvzibywmdsxpfwqhkgs.supabase.co',
    anonKey: 'sb_publishable_bSzg2zNFnv2wTDIMfGcGVA_YoHcGdvJ',
    // Deep-link scheme for auth email callbacks on mobile
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => owner_provider.AppStateProvider()..init()),
      ],
      child: const AgriConnectApp(),
    ),
  );
}

class AgriConnectApp extends StatelessWidget {
  const AgriConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDarkMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriConnect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatelessWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<AppState>().screen;

    Widget currentScreen;
    switch (screen) {
      case 'splash': currentScreen = const SplashScreen(); break;
      case 'language': currentScreen = const LanguageScreen(); break;
      case 'auth': currentScreen = const AuthScreen(); break;
      case 'role-selection': currentScreen = const RoleSelectionScreen(); break;
      case 'dashboard': currentScreen = const DashboardScreen(); break;
      case 'bookings': currentScreen = const BookingsScreen(); break;
      case 'tracking': currentScreen = const TrackingScreen(); break;
      case 'vehicle-status': currentScreen = const VehicleStatusScreen(); break; // Added this case
      case 'equipment-details': currentScreen = const EquipmentDetailsScreen(); break;
      case 'booking-details': currentScreen = const BookingDetailsScreen(); break;
      case 'damage-agreement': currentScreen = const DamageAgreementScreen(); break;
      case 'checkout': currentScreen = const CheckoutScreen(); break;
      case 'payment-status': currentScreen = const PaymentStatusScreen(); break;
      case 'vehicle-received': currentScreen = const VehicleReceivedScreen(); break;
      case 'review': currentScreen = const ReviewScreen(); break;
      case 'support': currentScreen = const SupportScreen(); break;
      case 'ai-advisor': currentScreen = const AiAdvisorScreen(); break;
      case 'profile': currentScreen = const ProfileScreen(); break;
      case 'settings': currentScreen = const SettingsScreen(); break;
      case 'damage-report': currentScreen = const DamageReportScreen(); break;
      case 'account-restricted': currentScreen = const AccountRestrictedScreen(); break;
      case 'contact-owner': currentScreen = const ContactOwnerScreen(); break;
      case 'notifications': currentScreen = const NotificationScreen(); break;
      case 'owner-dashboard': currentScreen = const owner_screens.MainLayout(); break;
      default:
        currentScreen = Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Screen "$screen" coming soon', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('dashboard'),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(screen),
        child: currentScreen,
      ),
    );
  }
}
