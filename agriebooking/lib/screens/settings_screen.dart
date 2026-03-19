import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.slate900;
    final subTextColor = isDark ? AppTheme.slate400 : AppTheme.slate500;
    final borderColor = isDark ? const Color(0xFF334155) : AppTheme.slate100;

    String langName = state.translate('english');
    if (state.language == 'ta') langName = state.translate('tamil');
    if (state.language == 'hi') langName = state.translate('hindi');

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: textColor),
                    onPressed: () => context.read<AppState>().setScreen('profile'),
                  ),
                  const SizedBox(width: 8),
                  Text(state.translate('settings'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.translate('preferences'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                      child: Column(
                        children: [
                          _buildListTile(context, LucideIcons.languages, state.translate('language'), langName, textColor, subTextColor, onTap: () {
                            _showLanguageSelection(context);
                          }),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchTile(LucideIcons.moon, state.translate('darkMode'), state.isDarkMode, textColor, (val) {
                            context.read<AppState>().setDarkMode(val);
                          }),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchTile(LucideIcons.bell, state.translate('pushNotifications'), state.notificationsEnabled, textColor, (val) {
                            context.read<AppState>().setNotificationsEnabled(val);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(state.translate('account'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                      child: Column(
                        children: [
                          _buildListTile(context, LucideIcons.lock, state.translate('privacySecurity'), null, textColor, subTextColor),
                          Divider(height: 1, color: borderColor),
                          _buildListTile(context, LucideIcons.trash2, state.translate('deleteAccount'), null, AppTheme.red500, subTextColor, onTap: () {
                            _showDeleteAccountDialog(context);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(state.translate('about'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                      child: Column(
                        children: [
                          _buildListTile(context, LucideIcons.fileText, state.translate('termsOfService'), null, textColor, subTextColor),
                          Divider(height: 1, color: borderColor),
                          _buildListTile(context, LucideIcons.shield, state.translate('privacyPolicy'), null, textColor, subTextColor),
                          Divider(height: 1, color: borderColor),
                          _buildListTile(context, LucideIcons.info, state.translate('appVersion'), 'v1.0.0', textColor, subTextColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.read<AppState>().translate('selectLanguage'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(title: Text(context.read<AppState>().translate('english')), onTap: () { context.read<AppState>().setLanguage('en'); Navigator.pop(ctx); }),
              ListTile(title: Text(context.read<AppState>().translate('tamil')), onTap: () { context.read<AppState>().setLanguage('ta'); Navigator.pop(ctx); }),
              ListTile(title: Text(context.read<AppState>().translate('hindi')), onTap: () { context.read<AppState>().setLanguage('hi'); Navigator.pop(ctx); }),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final state = Provider.of<AppState>(context, listen: false);
        return AlertDialog(
          title: Text(state.translate('deleteAccount')),
          content: Text(state.translate('deleteConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(state.translate('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red600),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AppState>().setScreen('auth');
              },
              child: Text(state.translate('yesDelete'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Color color, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.green600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String? trailingText, Color color, Color subColor, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: TextStyle(color: subColor)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, color: subColor, size: 16),
          ],
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
