import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/language_toggle.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        _buildProfileInfo(context),
                        _buildStatsGrid(context),
                        const SizedBox(height: 24),
                        _buildOptions(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const CustomBottomNavBar(activeScreen: 'profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.read<AppState>().translate('myProfile'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
          Row(
            children: [
              const LanguageToggle(),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(LucideIcons.settings, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => context.read<AppState>().setScreen('settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.read<AppState>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppTheme.slate200.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.green500, width: 3),
                  boxShadow: [
                    BoxShadow(color: AppTheme.green500.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)
                  ],
                ),
                child: Consumer<AppState>(
                  builder: (context, state, child) {
                    return ClipOval(
                      child: Image(
                        image: NetworkImage(state.userProfile?.avatar ?? 'https://randomuser.me/api/portraits/men/32.jpg'),
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AppState>().translate('uploading'))));
                      context.read<AppState>().updateProfileAvatar(File(pickedFile.path));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.green500,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 3),
                    ),
                    child: const Icon(LucideIcons.camera, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AppState>(
            builder: (context, state, child) {
              return Text(
                state.userProfile?.name ?? 'Rahul Kumar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.slate400),
              const SizedBox(width: 4),
              Flexible(
                child: Consumer<AppState>(
                  builder: (context, state, child) {
                    return GestureDetector(
                      onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController(text: state.userProfile?.location ?? state.currentLocationName);
                              return AlertDialog(
                                title: Text(state.translate('editAddress')),
                                content: TextField(controller: ctrl, decoration: InputDecoration(hintText: state.translate('enterNewAddress'))),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.translate('cancel'))),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<AppState>().updateProfile(location: ctrl.text);
                                      Navigator.pop(ctx);
                                    },
                                    child: Text(state.translate('save')),
                                  )
                                ],
                              );
                            }
                          );
                      },
                      child: Text(
                        state.userProfile?.location ?? state.currentLocationName,
                        style: TextStyle(fontSize: 14, color: AppTheme.slate500, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.green500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.green500.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.award, color: AppTheme.green600, size: 16),
                const SizedBox(width: 8),
                Text(
                  state.translate('premiumMember'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.green400 : AppTheme.green700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(context, '142', context.read<AppState>().translate('bookings'), LucideIcons.calendar, const Color(0xFF3B82F6)),
          _buildStatCard(context, '56', context.read<AppState>().translate('reviews'), LucideIcons.messageSquare, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.read<AppState>();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? const Color(0xFF334155) : AppTheme.slate100),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Consumer<AppState>(
            builder: (context, state, child) {
              final user = state.userProfile;
              return Column(
                children: [
                  _buildOptionItem(
                    context, 
                    LucideIcons.user, 
                    state.translate('accountSettings'), 
                    user?.email ?? state.translate('personalInfo'), 
                    isFirst: true
                  ),
                  if (user?.phone != null)
                    _buildOptionItem(
                      context, 
                      LucideIcons.phone, 
                      state.translate('phoneNum'), 
                      user!.phone,
                    ),
                  if (user?.aadhaar != null && user!.aadhaar!.isNotEmpty)
                    _buildOptionItem(
                      context, 
                      LucideIcons.shieldCheck, 
                      state.translate('aadhaarIdentity'), 
                      user.aadhaar!,
                    ),
                ],
              );
            },
          ),
          _buildOptionItem(context, LucideIcons.creditCard, state.translate('paymentMethods'), state.translate('paymentSub')),
          _buildOptionItem(context, Icons.agriculture, state.translate('myEquipment'), state.translate('manageListings')),
          _buildOptionItem(context, LucideIcons.headphones, state.translate('helpSupport'), state.translate('faqsContact'), onTap: () => state.setScreen('support')),
          _buildOptionItem(
            context,
            LucideIcons.arrowRightLeft,
            state.translate('switchToOwner'),
            state.translate('rentOutEquip'),
            onTap: () async {
              final auth = Supabase.instance.client.auth;
              if (auth.currentUser != null) {
                await Supabase.instance.client.from('users').update({'role': 'owner'}).eq('id', auth.currentUser!.id);
                if (context.mounted) {
                  state.setRole('owner');
                  state.setScreen('owner-dashboard');
                }
              }
            }
          ),
          _buildOptionItem(
            context, 
            LucideIcons.logOut, 
            state.translate('signOut'), 
            state.translate('logoutSub'), 
            color: const Color(0xFFEF4444), 
            isLast: true, 
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                state.setRole('farmer'); // Reset role
                state.setScreen('auth');
              }
            }
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final aadhaarController = TextEditingController(text: user.aadhaar);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<AppState>(context, listen: false).translate('editProfile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: Provider.of<AppState>(context, listen: false).translate('fullName'))),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: Provider.of<AppState>(context, listen: false).translate('phoneNum'))),
            TextField(controller: aadhaarController, decoration: InputDecoration(labelText: Provider.of<AppState>(context, listen: false).translate('aadhaarNum'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(Provider.of<AppState>(context, listen: false).translate('cancel'))),
          ElevatedButton(
            onPressed: () {
              final updated = user.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                aadhaar: aadhaarController.text,
              );
              context.read<AppState>().updateUserProfile(updated);
              Navigator.pop(context);
            },
            child: Text(Provider.of<AppState>(context, listen: false).translate('save')),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap, Color? color, bool isFirst = false, bool isLast = false}) {
    final effectiveColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    final state = context.read<AppState>();
    
    // Explicitly handle Account Settings tap if no onTap provided
    final VoidCallback? effectiveOnTap = onTap ?? (title == state.translate('accountSettings') && state.userProfile != null 
        ? () => _showEditProfileDialog(context, state.userProfile!) 
        : null);

    return InkWell(
      onTap: effectiveOnTap,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? 32 : 0),
        topRight: Radius.circular(isFirst ? 32 : 0),
        bottomLeft: Radius.circular(isLast ? 32 : 0),
        bottomRight: Radius.circular(isLast ? 32 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.green500).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppTheme.green600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: effectiveColor),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.slate400),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 20, color: AppTheme.slate300),
          ],
        ),
      ),
    );
  }

}
