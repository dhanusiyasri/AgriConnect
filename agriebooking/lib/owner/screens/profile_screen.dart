import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import '../../screens/support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        final profile = provider.userProfile;
        final mainState = context.watch<AppState>();
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8FBF8),
          appBar: AppBar(
            title: Text(mainState.translate('profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.settings),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2F7F33), width: 3),
                              image: DecorationImage(
                                image: NetworkImage(profile?.avatar ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&auto=format&fit=crop&w=256&q=80'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading...')));
                                  await context.read<AppStateProvider>().updateProfileAvatar(File(image.path));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F7F33),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile?.name ?? 'Harvest Farms Ltd.',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mainState.translate('verifiedOwner')} • ${mainState.translate('memberSince')} 2021',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat(provider.machinery.length.toString(), mainState.translate('vehicles')),
                          Container(width: 1, height: 30, color: Colors.grey[200]),
                          _buildProfileStat('4.9', mainState.translate('rating')),
                          Container(width: 1, height: 30, color: Colors.grey[200]),
                          _buildProfileStat('850+', mainState.translate('hours')),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Business Info Section
                _buildSectionHeader(mainState.translate('businessInfo')),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildProfileLink(context, LucideIcons.mail, mainState.translate('email'), profile?.email ?? mainState.translate('loading')),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.phone, mainState.translate('phone'), profile?.phone ?? mainState.translate('loading')),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.mapPin, mainState.translate('address'), profile?.location ?? mainState.translate('addAddress'), onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController(text: profile?.location);
                              return AlertDialog(
                                title: Text(mainState.translate('editAddress')),
                                content: TextField(controller: ctrl, decoration: InputDecoration(hintText: mainState.translate('enterNewAddress'))),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(mainState.translate('cancel'))),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<AppStateProvider>().updateProfile(location: ctrl.text);
                                      Navigator.pop(ctx);
                                    },
                                    child: Text(mainState.translate('save')),
                                  )
                                ],
                              );
                            }
                          );
                      }),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.creditCard, mainState.translate('paymentMethods'), mainState.translate('addCard')),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Settings Section
                _buildSectionHeader(mainState.translate('settings')),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildProfileLink(context, LucideIcons.bell, mainState.translate('notifications'), mainState.translate('on')),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.shieldCheck, mainState.translate('verificationSecurity'), mainState.translate('activeStatus')),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.lifeBuoy, mainState.translate('supportTitle'), '', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                      }),
                      _buildProfileLink(context, LucideIcons.arrowRightLeft, mainState.translate('switchToFarmer'), mainState.translate('bookEquipment'), onTap: () async {
                        final auth = Supabase.instance.client.auth;
                        if (auth.currentUser != null) {
                          await Supabase.instance.client.from('users').update({'role': 'farmer'}).eq('id', auth.currentUser!.id);
                          if (context.mounted) {
                            context.read<AppState>().setRole('farmer');
                            context.read<AppState>().setScreen('dashboard');
                          }
                        }
                      }),
                      const Divider(height: 1),
                      _buildProfileLink(context, LucideIcons.logOut, mainState.translate('logout'), '', isDestructive: true, onTap: () async {
                         await Supabase.instance.client.auth.signOut();
                         if (context.mounted) {
                           context.read<AppState>().setRole('farmer'); // Reset role
                           context.read<AppState>().setScreen('auth');
                         }
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'v1.0.0 (Build 42)',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLink(BuildContext context, IconData icon, String title, String value, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : const Color(0xFF2F7F33).withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF2F7F33), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.grey[600],
        ),
      ),
      subtitle: value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            )
          : null,
      trailing: Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}

