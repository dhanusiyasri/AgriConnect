import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  String _selectedTask = 'Harvesting';
  String _selectedSize = '1 Acre';
  String _selectedCrop = 'Rice';
  bool _showRecommendations = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F1E9), // Light green top
                    Color(0xFFE5D5B5), // Sand color
                    Color(0xFF7A978A), // Deeper greenish-grey
                    Color(0xFFE5D5B5), // Sand color bottom
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text('What work do you want to do today?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B4226))),
                          ),
                          const SizedBox(height: 12),
                          _buildTasksGrid(),
                          const SizedBox(height: 16),
                          _buildFarmDetails(),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                            child: Consumer<AppState>(
                              builder: (context, state, child) {
                                return ElevatedButton(
                                  onPressed: () {
                                    state.generateAiRecommendation(_selectedCrop, _selectedSize, _selectedTask);
                                    setState(() {
                                      _showRecommendations = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: state.isLoadingAiAdvice 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                );
                              },
                            ),
                            ),
                          ),
                            if (_showRecommendations) ...[
                              const SizedBox(height: 24),
                              Consumer<AppState>(
                                builder: (context, state, child) {
                                  if (state.customAiAdvice == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF166534).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: const Color(0xFF166534).withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.auto_awesome, color: Color(0xFF166534), size: 20),
                                              SizedBox(width: 8),
                                              Text('AI Personal Advice', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            state.customAiAdvice!,
                                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Color(0xFFFACC15), shape: BoxShape.circle),
                                      child: const Icon(LucideIcons.thumbsUp, color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Recommended Equipment For You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildEquipmentCard(
                                title: 'Tractor with Cultivator',
                                equipmentId: '1',
                                subtitle: 'Best for land preparation',
                                pricePerHour: '350',
                                pricePerDay: '1700',
                                imageColor: Colors.lightBlue,
                                isBestChoice: true,
                                distance: '3.2km away',
                                rating: '4.8 (120+)',
                                nearbyText: '3 machines nearby',
                              ),
                            ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF166534)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (Navigator.canPop(context))
                const SizedBox(width: 8),
              const Icon(Icons.agriculture, color: Color(0xFF166534), size: 28),
              const SizedBox(width: 8),
              const Text(
                'Smart Equipment\nAdvisor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE9DF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB0D2B8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF15803D), size: 14),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                        height: 1,
                      ),
                    ),
                    Text(
                      'SMART',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksGrid() {
    final tasks = [
      {'icon': Icons.local_florist, 'label': 'Land Prep'},
      {'icon': Icons.agriculture, 'label': 'Harvesting'},
      {'icon': Icons.eco, 'label': 'Seed Planting'},
      {'icon': Icons.water_drop, 'label': 'Spraying'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isSelected = _selectedTask == task['label'];
          return GestureDetector(
            onTap: () => setState(() => _selectedTask = task['label'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: isSelected ? Border.all(color: const Color(0xFF166534), width: 2) : Border.all(color: Colors.transparent, width: 2),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF166534) : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(task['icon'] as IconData, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(task['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Color(0xFF6B4226), size: 20),
              const SizedBox(width: 8),
              Text('Farm Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('FARM SIZE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPill('1 Acre', _selectedSize == '1 Acre', isGreen: true, onTap: () => setState(() => _selectedSize = '1 Acre')),
              const SizedBox(width: 8),
              _buildPill('2-5 Acres', _selectedSize == '2-5 Acres', onTap: () => setState(() => _selectedSize = '2-5 Acres')),
              const SizedBox(width: 8),
              _buildPill('5+ Acres', _selectedSize == '5+ Acres', onTap: () => setState(() => _selectedSize = '5+ Acres')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('CROP TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPill('Rice', _selectedCrop == 'Rice', isBrown: true, onTap: () => setState(() => _selectedCrop = 'Rice')),
                const SizedBox(width: 8),
                _buildPill('Wheat', _selectedCrop == 'Wheat', onTap: () => setState(() => _selectedCrop = 'Wheat')),
                const SizedBox(width: 8),
                _buildPill('Corn', _selectedCrop == 'Corn', onTap: () => setState(() => _selectedCrop = 'Corn')),
                const SizedBox(width: 8),
                _buildPill('Cotton', _selectedCrop == 'Cotton', onTap: () => setState(() => _selectedCrop = 'Cotton')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected, {bool isGreen = false, bool isBrown = false, required VoidCallback onTap}) {
    Color bgColor = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF475569);

    if (isSelected) {
      if (isGreen) {
        bgColor = const Color(0xFF16A34A);
        textColor = Colors.white;
      } else if (isBrown) {
        bgColor = const Color(0xFF16A34A); // Use green for all selections per prompt requirement
        textColor = Colors.white;
      } else {
        bgColor = const Color(0xFF16A34A);
        textColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }

  Widget _buildEquipmentCard({
    required String title,
    required String equipmentId,
    required String subtitle,
    required String pricePerHour,
    required String pricePerDay,
    required Color imageColor,
    required bool isBestChoice,
    String? distance,
    String? rating,
    String? nearbyText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: isBestChoice ? 140 : 100, // Make best choice image taller
                width: double.infinity,
                decoration: BoxDecoration(
                  color: imageColor,
                  borderRadius: isBestChoice ? const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)) : BorderRadius.circular(24),
                  // Mocking an image with gradient for aesthetic
                  gradient: isBestChoice ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF93C5FD)], begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
                ),
                margin: isBestChoice ? EdgeInsets.zero : const EdgeInsets.only(left: 16, top: 16, right: 16),
              ),
              if (isBestChoice)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(16)),
                    child: const Text('BEST CHOICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF854D0E))),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.titleLarge?.color)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '₹$pricePerHour', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                          const TextSpan(text: '/hr\n', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          TextSpan(text: '₹$pricePerDay', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                          const TextSpan(text: '/day', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                if (distance != null && rating != null && nearbyText != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF16A34A), size: 14),
                          const SizedBox(width: 4),
                          Text(distance, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFACC15), size: 14),
                          const SizedBox(width: 4),
                          Text(rating, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ],
                      ),
                      Text(nearbyText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: isBestChoice ? const Color(0xFF785340) : const Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isBestChoice ? 'View Machines' : 'View Nearby', style: TextStyle(fontWeight: FontWeight.bold, color: isBestChoice ? const Color(0xFF785340) : const Color(0xFF0F172A))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final allEquipment = context.read<AppState>().filteredEquipment;
                          final eq = allEquipment.firstWhere(
                            (e) => e.id == equipmentId,
                            orElse: () => allEquipment.isNotEmpty ? allEquipment.first : throw Exception("No equipments available"),
                          );
                          context.read<AppState>().setSelectedEquipment(eq);
                          context.read<AppState>().setScreen('booking-details');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBestChoice ? const Color(0xFF22C55E) : const Color(0xFF785340), // green or brown
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.home, 'Home', 'dashboard', false, colorOverride: const Color(0xFF15803D)),
            _buildNavItem(context, Icons.explore, 'Advisor', 'support', true),
            _buildNavItem(context, Icons.calendar_today, 'Bookings', 'bookings', false),
            _buildNavItem(context, Icons.person, 'Profile', 'profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String screen, bool isActive, {Color? colorOverride}) {
    final color = isActive ? const Color(0xFF64748B) : (colorOverride ?? const Color(0xFF94A3B8));
    return GestureDetector(
      onTap: () => context.read<AppState>().setScreen(screen),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
