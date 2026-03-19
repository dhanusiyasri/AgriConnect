import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import 'vehicle_details_screen.dart';
import 'add_vehicle_screen.dart';

class MachineryScreen extends StatelessWidget {
  const MachineryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final machinery = context.watch<AppStateProvider>().machinery;
    final mainState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(mainState.translate('myMachinery')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: machinery.length,
        itemBuilder: (context, index) {
          final item = machinery[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehicleDetailsScreen(equipment: item)),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.image.startsWith('http') 
                        ? Image.network(
                            item.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.agriculture, color: Colors.grey),
                            ),
                          )
                        : Image.file(
                            File(item.image),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.agriculture, color: Colors.grey),
                            ),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.model,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${item.pricePerHour.toStringAsFixed(0)}/${mainState.translate('hr')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2F7F33),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      '₹${item.pricePerDay.toStringAsFixed(0)}/${mainState.translate('day')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.status == 'available' 
                                      ? Colors.green[100] 
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  mainState.translate(item.status.toLowerCase()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.status == 'available' 
                                        ? Colors.green[800] 
                                        : Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddVehicleScreen()));
        },
        backgroundColor: const Color(0xFF2F7F33),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
