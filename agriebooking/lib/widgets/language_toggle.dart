import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return PopupMenuButton<String>(
          initialValue: state.language,
          onSelected: (String lang) => state.setLanguage(lang),
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.green50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.green100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.language == 'ta' ? 'த' : (state.language == 'hi' ? 'हि' : 'A'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.green700,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.green700),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            _buildMenuItem('en', 'English', 'A'),
            const PopupMenuDivider(),
            _buildMenuItem('ta', 'தமிழ்', 'த'),
            const PopupMenuDivider(),
            _buildMenuItem('hi', 'हिन्दी', 'हि'),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, String symbol) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.green50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(symbol, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.green700)),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
