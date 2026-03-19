import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => context.read<AppState>().setScreen('dashboard'),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<AppState>().markAllNotificationsRead(),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppTheme.green700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final notifications = state.notifications;
          if (notifications.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationTile(context, state, notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.green100,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bellOff, color: AppTheme.green700, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You're all caught up! We'll notify you\nwhen something important happens.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.slate400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppState state, AppNotification notif) {
    final iconData = _iconForType(notif.type);
    final iconColor = _colorForType(notif.type);

    return Material(
      color: notif.isRead
          ? Colors.transparent
          : AppTheme.green100.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          state.markNotificationRead(notif.id);
          if (notif.bookingId != null) {
            state.setScreen('bookings');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.green700,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: const TextStyle(fontSize: 13, color: AppTheme.slate500, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notif.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppTheme.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking': return LucideIcons.calendar;
      case 'payment': return LucideIcons.creditCard;
      case 'ai': return Icons.auto_awesome;
      case 'tracking': return LucideIcons.mapPin;
      case 'insurance': return LucideIcons.shield;
      default: return LucideIcons.bell;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'booking': return AppTheme.green700;
      case 'payment': return const Color(0xFF8B5CF6);
      case 'ai': return const Color(0xFFF59E0B);
      case 'tracking': return const Color(0xFF3B82F6);
      case 'insurance': return const Color(0xFFEF4444);
      default: return AppTheme.slate400;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
