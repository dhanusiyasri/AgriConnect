import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _handleRoleSelection(BuildContext context, String role) async {
    try {
      final state = context.read<AppState>();
      final userProfile = state.userProfile;
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null && userProfile != null) {
        // Only insert if it's a new registration; if they somehow hit this on login, 
        // upsert will update their role
        await Supabase.instance.client.from('users').upsert({
          'id': user.id,
          'name': userProfile.name,
          'email': userProfile.email,
          'phone': userProfile.phone,
          'aadhaar_number': userProfile.aadhaar,
          'role': role,
        });
      }
      
      if (context.mounted) {
        state.setRole(role);
        state.setScreen(role == 'farmer' ? 'dashboard' : 'owner-dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              const SizedBox(height: 32),
              Text(
                'Welcome to AgriConnect',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to use the platform',
                style: TextStyle(fontSize: 16, color: AppTheme.slate500),
              ),
              const SizedBox(height: 48),

              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      title: 'Farmer',
                      description: 'Book tractors and farm machinery near your village to boost your productivity.',
                      image: 'https://images.rawpixel.com/image_social_landscape/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDI0LTAxL3Jhd3BpeGVsb2ZmaWNlMTJfcGhvdG9fb2ZfYW5faW5kaWFuX2Zhcm1lcl9kb2luZ19hZ3JpY3VsdHVyZV9zbV84M2Y5ODI4MC05MGFlLTRmZTEtOWQ3NS0xMjM4MWI5MTMxZjZfMS5qcGc.jpg',
                      buttonText: 'Continue as Farmer',
                      onTap: () => _handleRoleSelection(context, 'farmer'),
                      isActive: true,
                    ),
                    const SizedBox(height: 24),
                    _RoleCard(
                      title: 'Owner',
                      description: 'Rent your tractors and equipment to farmers and earn extra income from your machinery.',
                      image: 'https://tse1.mm.bing.net/th/id/OIP.jCtMUYhf46vKAzT-l64eZwHaEK?rs=1&pid=ImgDetMain&o=7&rm=3',
                      buttonText: 'Continue as Owner',
                      onTap: () => _handleRoleSelection(context, 'owner'),
                      isActive: true,
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final VoidCallback onTap;
  final bool isActive;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.slate100),
          boxShadow: [
            BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(image, height: 160, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14, color: AppTheme.slate500)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActive ? onTap : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppTheme.green700 : AppTheme.slate100,
                        foregroundColor: isActive ? Colors.white : AppTheme.slate500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.chevronRight, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
