import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../providers/app_state_provider.dart';
import '../../providers/app_state.dart' show AppState;

class RequestDetailsScreen extends StatelessWidget {
  final FarmerRequest request;
  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final mainState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mainState.translate('requestDetails')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF2F7F33).withOpacity(0.05),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(request.farmerAvatar ?? 'https://i.pravatar.cc/150?u=${request.farmerName}'),
                    radius: 35,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.farmerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F7F33).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                request.farmerType,
                                style: const TextStyle(color: Color(0xFF2F7F33), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 14),
                                const SizedBox(width: 4),
                                Text('${request.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(' (${request.reviewsCount} reviews)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${mainState.translate('memberSince')} ${request.memberSince}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment Requested
                  Text(mainState.translate('equipmentReq'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailRow(LucideIcons.truck, request.equipmentName),
                  _buildDetailRow(LucideIcons.clock, request.duration),
                  _buildDetailRow(LucideIcons.mapPin, request.location),
                  _buildDetailRow(LucideIcons.navigation, '${request.distance} ${mainState.translate('away')}'),
                  
                  const SizedBox(height: 24),
                  Text(mainState.translate('driverReq'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: request.requiresDriver == true ? Colors.orange[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          request.requiresDriver == true ? LucideIcons.userCheck : LucideIcons.userMinus,
                          color: request.requiresDriver == true ? Colors.orange[700] : Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.requiresDriver == true ? mainState.translate('driverRequested') : mainState.translate('noDriverNeeded'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: request.requiresDriver == true ? Colors.orange[900] : Colors.blue[900],
                                ),
                              ),
                              Text(
                                request.requiresDriver == true 
                                  ? mainState.translate('driverReqHelp') 
                                  : mainState.translate('noDriverNeededHelp'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: request.requiresDriver == true ? Colors.orange[700] : Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Job Note
                  if (request.note != null) ...[
                    Text(mainState.translate('jobNote'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        request.note!,
                        style: TextStyle(color: Colors.grey[800], height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Payment Breakdown
                  if (request.breakdown != null) ...[
                    Text(mainState.translate('proposedPayment'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPaymentRow(mainState.translate('rentalFee'), '₹${request.breakdown!.rentalFee}'),
                    _buildPaymentRow(mainState.translate('insurance'), '₹${request.breakdown!.insurance}'),
                    _buildPaymentRow(mainState.translate('platformFee'), '₹${request.breakdown!.platformFee}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _buildPaymentRow(mainState.translate('totalEarnings'), '₹${request.breakdown!.total}', isTotal: true),
                  ],

                  const SizedBox(height: 40),

                  // Action Buttons (if pending)
                  if (request.status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<AppStateProvider>().updateRequestStatus(request.id, 'declined');
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                               minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                             child: FittedBox(
                               fit: BoxFit.scaleDown,
                               child: Text(mainState.translate('rejectBooking')),
                             ),
                           ),
                         ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AppStateProvider>().updateRequestStatus(request.id, 'accepted');
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F7F33),
                               minimumSize: const Size(0, 56),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                             ),
                             child: FittedBox(
                               fit: BoxFit.scaleDown,
                               child: Text(mainState.translate('approveBooking'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                             ),
                           ),
                         ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: request.status == 'accepted' ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${mainState.translate('requestStatusInfo')} ${mainState.translate(request.status!.toLowerCase())}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: request.status == 'accepted' ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(
                color: isTotal ? Colors.black : Colors.grey[600], 
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount, 
            style: TextStyle(
              fontSize: isTotal ? 18 : 14, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, 
              color: isTotal ? const Color(0xFF2F7F33) : Colors.black
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
