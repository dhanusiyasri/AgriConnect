import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.fetchLocation();
      state.fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildWeatherCard(),
                  _buildVoiceBookingToggle(context),
                  _buildSearchAndVoice(context),
                  _buildVoiceGuide(context),
                  _buildCategories(context),
                  _buildNearbyEquipment(context),
                ],
              ),
            ),
            const CustomBottomNavBar(activeScreen: 'dashboard'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.read<AppState>().fetchLocation(),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.green100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture, color: AppTheme.green700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.read<AppState>().translate('currentLocation'), style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
                        Consumer<AppState>(
                          builder: (context, state, child) {
                            return Text(
                              state.currentLocationName == 'Fetching location...' 
                                  ? state.translate('fetchingLoc') 
                                  : state.currentLocationName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LanguageToggle(),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  context.read<AppState>().translate('helloFarmer'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.green700, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Consumer<AppState>(
                builder: (context, state, _) {
                  final count = state.unreadCount;
                  return GestureDetector(
                    onTap: () => state.setScreen('notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.slate100),
                          ),
                          child: Icon(Icons.notifications_outlined, color: Theme.of(context).textTheme.bodyLarge?.color, size: 22),
                        ),
                        if (count > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Consumer<AppState>(
      builder: (context, state, child) {
        if (state.isLoadingWeather) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final weather = state.weatherData;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.green700, AppTheme.green600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.green700.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate(weather?['condition']?.toString().toLowerCase() ?? 'sunny'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.translate('idealFor')} ${state.currentLocationName.split(',').first}',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildWeatherStat(LucideIcons.droplets, '${weather?['hum'] ?? 62}%'),
                          const SizedBox(width: 16),
                          Expanded(child: _buildWeatherStat(LucideIcons.wind, weather?['wind'] ?? '14km/h')),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${weather?['temp'] ?? 32}°C',
                  style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }  Widget _buildVoiceBookingToggle(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: state.voiceBookingEnabled ? AppTheme.green700.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: state.voiceBookingEnabled ? AppTheme.green700 : AppTheme.slate100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(LucideIcons.mic, color: state.voiceBookingEnabled ? AppTheme.green700 : AppTheme.slate400, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.translate('voiceMode'), 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: state.voiceBookingEnabled ? AppTheme.green700 : Theme.of(context).textTheme.bodyLarge?.color
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              state.voiceBookingEnabled ? state.translate('listening') : state.translate('enableVoice'),
                              style: const TextStyle(fontSize: 12, color: AppTheme.slate400),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.voiceBookingEnabled,
                  onChanged: (val) => state.setVoiceBookingEnabled(val),
                  activeThumbColor: AppTheme.green700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndVoice(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => state.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: state.translate('searchEquipment'),
                      hintStyle: const TextStyle(color: AppTheme.slate400),
                      prefixIcon: const Icon(LucideIcons.search, color: AppTheme.slate400, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => state.toggleListening(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.isListening ? Colors.red : AppTheme.green700,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: state.isListening ? [
                      BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
                    ] : null,
                  ),
                  child: Icon(
                    state.isListening ? LucideIcons.mic : LucideIcons.mic, 
                    color: Colors.white, 
                    size: 24
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildVoiceGuide(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.voiceBookingStage == 'idle' && !state.isListening) return const SizedBox.shrink();

    String guideText = "Say equipment name (e.g. 'Tractor')";
    if (state.voiceBookingStage == 'searching') guideText = "Say 'Details' for more info";
    if (state.voiceBookingStage == 'detailing') guideText = "Say 'Confirm' or 'Book'";
    if (state.voiceBookingStage == 'confirming') guideText = "Say 'Pay' to complete";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.green700.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.green700.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.green700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.isListening ? "Listening: \"${state.lastWords}\"" : guideText,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.green700),
            ),
          ),
          if (state.voiceBookingStage != 'idle')
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.green700),
              onPressed: () => state.setVoiceBookingStage('idle'),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.green700 : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppTheme.green700 : AppTheme.slate200),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.white : AppTheme.green700, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.green700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'icon': Icons.agriculture, 'label': 'Tractor'},
      {'icon': LucideIcons.settings, 'label': 'Rotavator'},
      {'icon': Icons.precision_manufacturing, 'label': 'Harvester'},
      {'icon': Icons.grass, 'label': 'Seed Drill'},
      {'icon': Icons.water_drop, 'label': 'Sprayer'},
      {'icon': Icons.hardware, 'label': 'Plough'},
      {'icon': Icons.local_shipping, 'label': 'Water Tank'},
      {'icon': Icons.cut, 'label': 'Mower'},
      {'icon': Icons.fire_truck, 'label': 'Baler'},
    ];

    return Consumer<AppState>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(state.translate('bookMachinery'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final label = categories[index]['label'] as String;
                  final isActive = state.searchQuery.toLowerCase() == label.toLowerCase();
                  return GestureDetector(
                    onTap: () => state.setSearchQuery(label),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.green700 : Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: isActive ? AppTheme.green700 : AppTheme.slate100),
                            boxShadow: [
                              BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Icon(categories[index]['icon'] as IconData, color: isActive ? Colors.white : AppTheme.green700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.translate(label.toLowerCase()),
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: isActive ? AppTheme.green700 : AppTheme.slate600, 
                            letterSpacing: 0.5
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final allCategories = [
          {'icon': Icons.agriculture, 'label': 'Tractor'},
          {'icon': LucideIcons.settings, 'label': 'Rotavator'},
          {'icon': Icons.precision_manufacturing, 'label': 'Harvester'},
          {'icon': Icons.grass, 'label': 'Seed Drill'},
          {'icon': Icons.water_drop, 'label': 'Sprayer'},
          {'icon': Icons.hardware, 'label': 'Plough'},
          {'icon': Icons.local_shipping, 'label': 'Water Tank'},
          {'icon': Icons.cut, 'label': 'Mower'},
          {'icon': Icons.fire_truck, 'label': 'Baler'},
        ];
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('All Equipment Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.slate100),
                          ),
                          child: Icon(allCategories[index]['icon'] as IconData, color: AppTheme.green700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (allCategories[index]['label'] as String).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slate600, letterSpacing: 0.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNearbyEquipment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.read<AppState>().translate('nearbyEquipment'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
             /* TextButton(
                onPressed: () {},
                child: const Text('View Map', style: TextStyle(color: AppTheme.green700, fontWeight: FontWeight.bold)),
              ),*/
            ],
          ),
          const SizedBox(height: 8),
          Consumer<AppState>(
            builder: (context, state, child) {
              final filtered = state.filteredEquipment;
              return Column(
                children: filtered.map((eq) => _buildEquipmentCard(context, state, eq)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, AppState state, Equipment eq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate100),
        boxShadow: [
          BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                eq.image,
                height: 192,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 192,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF166534), Color(0xFF4ade80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.agriculture, color: Colors.white, size: 56),
                      const SizedBox(height: 8),
                      Text(
                        eq.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.star, color: AppTheme.amber400, size: 14),
                      const SizedBox(width: 4),
                      Text(eq.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eq.name, 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, color: AppTheme.slate400, size: 12),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text('${eq.village} (${eq.distance} away)', style: const TextStyle(fontSize: 12, color: AppTheme.slate400), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('₹${eq.pricePerHour}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.green700)),
                                Text(' /${state.translate('pricePerHour').split(' ').last}', style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.translate('recommendedFor')} ${state.currentLocationName.split(',').first}. ${state.translate('bestFor')} ${state.translate(state.weatherData?['condition']?.toString().toLowerCase() ?? 'sunny')} ${state.translate('weatherCondition')}.',
                            style: const TextStyle(fontSize: 11, color: AppTheme.slate500, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AppState>().setSelectedEquipment(eq);
                      context.read<AppState>().setScreen('equipment-details');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(state.translate('bookNow'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
