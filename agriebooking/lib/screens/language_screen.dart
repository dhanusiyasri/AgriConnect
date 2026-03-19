import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
              IconButton(
                onPressed: () => context.read<AppState>().setScreen('splash'),
                icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 32),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.green50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(LucideIcons.languages, size: 32, color: AppTheme.green600),
              ),
              const SizedBox(height: 32),
              
              Text(
                state.translate('selectLanguage'),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color, height: 1.2),
              ),
              const SizedBox(height: 16),
              Text(
                state.translate('langSub'),
                style: const TextStyle(fontSize: 16, color: AppTheme.slate500),
              ),
              const SizedBox(height: 48),

              Expanded(
                child: Column(
                  children: [
                    _LangCard(id: 'ta', label: 'தமிழ்', sub: 'Tamil', symbol: 'த', state: state),
                    const SizedBox(height: 16),
                    _LangCard(id: 'en', label: 'English', sub: 'Default', symbol: 'A', state: state),
                    const SizedBox(height: 16),
                    _LangCard(id: 'hi', label: 'हिंदी', sub: 'Hindi', symbol: 'हि', state: state),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AppState>().setScreen('auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green100,
                  ),
                  child: Text(state.translate('continueText'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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

class _LangCard extends StatelessWidget {
  final String id;
  final String label;
  final String sub;
  final String symbol;
  final AppState state;

  const _LangCard({required this.id, required this.label, required this.sub, required this.symbol, required this.state});

  @override
  Widget build(BuildContext context) {
    bool isSelected = state.language == id;
    return GestureDetector(
      onTap: () => context.read<AppState>().setLanguage(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.green50.withOpacity(0.5) : Theme.of(context).colorScheme.surface,
          border: Border.all(color: isSelected ? AppTheme.green600 : AppTheme.slate100, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(symbol, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text(sub, style: const TextStyle(fontSize: 14, color: AppTheme.slate500)),
                ],
              ),
            ),
            if (isSelected) const Icon(LucideIcons.checkCircle2, color: AppTheme.green600),
          ],
        ),
      ),
    );
  }
}
