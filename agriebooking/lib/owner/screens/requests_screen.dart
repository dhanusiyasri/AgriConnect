import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;
import 'request_details_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppStateProvider>().requests;

    return Scaffold(
      appBar: AppBar(title: Text(context.watch<AppState>().translate('requests'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RequestDetailsScreen(request: req)),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            req.farmerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            context.read<AppState>().translate(req.status?.toLowerCase() ?? 'pending'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(req.equipmentName, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(req.distance, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        if (req.requiresDriver == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, size: 10, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                  Text(
                                    context.read<AppState>().translate('driverRequested'),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (req.status == 'pending')
                      Row(
                        children: [
                          Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<AppStateProvider>().updateRequestStatus(req.id, 'declined');
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(context.read<AppState>().translate('decline')),
                                  ),
                                ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<AppStateProvider>().updateRequestStatus(req.id, 'accepted');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F7F33)),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(context.read<AppState>().translate('accept'), style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
