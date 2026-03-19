import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  DateTime? _selectedDate;
  final Set<String> _selectedSlots = {};

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.green700,
              onPrimary: Colors.white,
              onSurface: AppTheme.slate900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatDate(AppState state, DateTime? date) {
    if (date == null) return state.translate('selectDate');
    const monthKeys = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return '${state.translate(monthKeys[date.month - 1])} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final equipment = state.selectedEquipment;
    if (equipment == null) return const SizedBox.shrink();

    // Calculate price based on selected slots if hourly, else base price
    final int basePrice = state.bookingType == 'hourly' ? equipment.pricePerHour : equipment.pricePerDay;
    final int multiplier = state.bookingType == 'hourly' ? (_selectedSlots.isNotEmpty ? _selectedSlots.length : 1) : 1;
    final int price = basePrice * multiplier;

    final int serviceFee = 150;
    final int expressFee = state.isExpressBooking ? 200 : 0;
    final int driverFee = state.withDriver ? (state.bookingType == 'hourly' ? 200 * multiplier : 1500) : 0;
    final int total = price + serviceFee + expressFee + driverFee;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
                              child: IconButton(
                                icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                                onPressed: () => context.read<AppState>().setScreen('equipment-details'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(state.translate('bookingsTitle'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<AppState>().setBookingType('hourly');
                                  setState(() => _selectedSlots.clear());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: state.bookingType == 'hourly' ? AppTheme.green700 : Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(state.translate('pricePerHour').split(' ').last, style: TextStyle(fontWeight: FontWeight.bold, color: state.bookingType == 'hourly' ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<AppState>().setBookingType('daily');
                                  setState(() => _selectedSlots.clear());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: state.bookingType == 'daily' ? AppTheme.green700 : Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(state.translate('fullDay'), style: TextStyle(fontWeight: FontWeight.bold, color: state.bookingType == 'daily' ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(state.translate('selectDate').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.slate100)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.calendar, color: AppTheme.green700, size: 20),
                                    const SizedBox(width: 12),
                                    Text(_selectedDate == null ? state.translate('selectDate') : _formatDate(state, _selectedDate), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  ],
                                ),
                                const Icon(LucideIcons.chevronDown, color: AppTheme.slate400, size: 20),
                              ],
                            ),
                          ),
                        ),
                        if (state.bookingType == 'hourly') ...[
                          const SizedBox(height: 24),
                          Text(state.translate('selectHours').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.5,
                            children: (equipment.availableSlots.isNotEmpty ? equipment.availableSlots : ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM']).map((slot) {
                              bool isSelected = _selectedSlots.contains(slot);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected ? _selectedSlots.remove(slot) : _selectedSlots.add(slot);
                                  });
                                  if (_selectedSlots.isNotEmpty) {
                                    context.read<AppState>().setSelectedSlot(_selectedSlots.first);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.green700 : Theme.of(context).scaffoldBackgroundColor,
                                    border: Border.all(color: isSelected ? AppTheme.green700 : AppTheme.slate200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(slot, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100), boxShadow: [BoxShadow(color: AppTheme.slate100.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2))]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: AppTheme.green100, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.person, color: AppTheme.green700, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(state.translate('withDriver'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                        Text(state.translate('driverReqHelp'), style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.read<AppState>().setWithDriver(!state.withDriver),
                                child: Container(
                                  width: 48,
                                  height: 24,
                                  decoration: BoxDecoration(color: state.withDriver ? AppTheme.green600 : AppTheme.slate200, borderRadius: BorderRadius.circular(12)),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: state.withDriver ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100), boxShadow: [BoxShadow(color: AppTheme.slate100.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2))]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: AppTheme.orange50, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(LucideIcons.zap, color: AppTheme.orange600, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(state.translate('expressBooking'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                      Text(state.translate('fasterApproval'), style: const TextStyle(fontSize: 12, color: AppTheme.slate400)),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => context.read<AppState>().setIsExpressBooking(!state.isExpressBooking),
                                child: Container(
                                  width: 48,
                                  height: 24,
                                  decoration: BoxDecoration(color: state.isExpressBooking ? AppTheme.green600 : AppTheme.slate200, borderRadius: BorderRadius.circular(12)),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: state.isExpressBooking ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.slate100), boxShadow: [BoxShadow(color: AppTheme.slate100.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.translate('totalCost'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${state.translate('rentalFee')} (${state.bookingType == 'hourly' ? '${_selectedSlots.isNotEmpty ? _selectedSlots.length : 1} ${state.translate('hours')}' : state.translate('day')})', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                  Text('₹$price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(state.translate('platformFee'), style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                  Text('₹$serviceFee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                ],
                              ),
                              if (state.isExpressBooking) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(state.translate('expressDelivery'), style: const TextStyle(fontSize: 14, color: AppTheme.slate500)),
                                    Text('₹$expressFee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  ],
                                ),
                              ],
                              if (state.withDriver) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(state.translate('driverFee'), style: const TextStyle(fontSize: 14, color: AppTheme.slate500)),
                                    Text('₹$driverFee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(color: AppTheme.slate100),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(state.translate('totalCost'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.green700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: const Border(top: BorderSide(color: AppTheme.slate100))),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate('pleaseSelectDate'))));
                      return;
                    }
                    if (state.bookingType == 'hourly' && _selectedSlots.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate('pleaseSelectSlot'))));
                      return;
                    }
                    context.read<AppState>().setScreen('damage-agreement');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppTheme.green200,
                  ),
                  child: Text(state.translate('confirmBooking'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
