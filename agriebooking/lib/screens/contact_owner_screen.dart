import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ContactOwnerScreen extends StatelessWidget {
  const ContactOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ownerName = state.selectedEquipment?.owner.name ?? 'Owner';

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
                    onPressed: () => context.read<AppState>().setScreen('vehicle-received'),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network('https://picsum.photos/seed/owner2/100/100', width: 40, height: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ownerName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.green500, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('Online', style: TextStyle(fontSize: 12, color: AppTheme.slate500)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.phone, color: AppTheme.green700),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildMessage(
                    isOwner: true,
                    text: 'Hello! I am arriving with the tractor in 10 mins.',
                    time: '08:45 AM',
                  ),
                  _buildMessage(
                    isOwner: false,
                    text: 'Okay, I am at the farm entrance.',
                    time: '08:47 AM',
                  ),
                  _buildMessage(
                    isOwner: true,
                    text: 'Perfect. See you soon.',
                    time: '08:48 AM',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.slate100))),
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: AppTheme.slate50, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.paperclip, color: AppTheme.slate500, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(color: AppTheme.slate400),
                          filled: true,
                          fillColor: AppTheme.slate50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: AppTheme.green600, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.green200, blurRadius: 8, offset: Offset(0, 4))]),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
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

  Widget _buildMessage({required bool isOwner, required String text, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isOwner ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isOwner) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network('https://picsum.photos/seed/owner2/100/100', width: 32, height: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwner ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isOwner ? Colors.white : AppTheme.green600,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isOwner ? Radius.zero : const Radius.circular(20),
                      bottomRight: isOwner ? const Radius.circular(20) : Radius.zero,
                    ),
                    border: isOwner ? Border.all(color: AppTheme.slate100) : null,
                  ),
                  child: Text(text, style: TextStyle(color: isOwner ? AppTheme.slate800 : Colors.white, height: 1.5)),
                ),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.slate400, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (!isOwner) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppTheme.slate100, shape: BoxShape.circle),
              child: const Icon(LucideIcons.user, color: AppTheme.slate600, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
