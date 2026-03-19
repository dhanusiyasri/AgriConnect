import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'ai_advisor_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? expandedFaq;

  final faqs = [
    {'q': 'faq1_q', 'a': 'faq1_a'},
    {'q': 'faq2_q', 'a': 'faq2_a'},
    {'q': 'faq3_q', 'a': 'faq3_a'},
    {'q': 'faq4_q', 'a': 'faq4_a'},
    {'q': 'faq5_q', 'a': 'faq5_a'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.read<AppState>().setScreen('dashboard');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(context.read<AppState>().translate('supportAssistance'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppTheme.green700, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.read<AppState>().translate('howHelp'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text(context.read<AppState>().translate('supportSub'), style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        children: [
                                          const Icon(LucideIcons.phone, color: Colors.white, size: 20),
                                          const SizedBox(height: 8),
                                          Text(context.read<AppState>().translate('callUs'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAdvisorScreen()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                                        child: Column(
                                          children: [
                                            const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                                            const SizedBox(height: 8),
                                            Text(context.read<AppState>().translate('aiRecommender'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(context.read<AppState>().translate('faqs'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                        ),
                        const SizedBox(height: 12),
                        ...faqs.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var faq = entry.value;
                          bool isExpanded = expandedFaq == idx;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.slate100),
                              boxShadow: [BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  expandedFaq = isExpanded ? null : idx;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(context.read<AppState>().translate(faq['q']!), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
                                        Icon(
                                          LucideIcons.chevronRight,
                                          color: AppTheme.slate300,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 16),
                                      Text(context.read<AppState>().translate(faq['a']!), style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const CustomBottomNavBar(activeScreen: 'support'),
          ],
        ),
      ),
    );
  }

}
