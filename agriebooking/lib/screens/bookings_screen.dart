import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  bool _showActive = true;
  late AnimationController _emptyAnim;
  late Animation<double> _emptyFade;

  @override
  void initState() {
    super.initState();
    _emptyAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _emptyFade = CurvedAnimation(parent: _emptyAnim, curve: Curves.easeOut);
    _emptyAnim.forward();
  }

  @override
  void dispose() {
    _emptyAnim.dispose();
    super.dispose();
  }

  List<dynamic> _filterBookings(List<dynamic> bookings) {
    final activeStatuses = {'REQUESTED', 'CONFIRMED', 'IN_PROGRESS', 'PAYMENT_PENDING', 'active', 'ACCEPTED'};
    if (_showActive) {
      return bookings.where((b) => activeStatuses.contains(b.status.toUpperCase())).toList();
    } else {
      return bookings.where((b) => !activeStatuses.contains(b.status.toUpperCase())).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<AppState>().bookings;
    final filteredBookings = _filterBookings(bookings);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                _buildTabs(),
                Expanded(
                  child: filteredBookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            return _AnimatedBookingCard(
                              booking: filteredBookings[index],
                              index: index,
                              isActive: _showActive,
                            );
                          },
                        ),
                ),
              ],
            ),
            const CustomBottomNavBar(activeScreen: 'bookings'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () => context.read<AppState>().setScreen('dashboard'),
          ),
          const SizedBox(width: 8),
          Text(context.read<AppState>().translate('myBookings'),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color)),
          const Spacer(),
          Consumer<AppState>(
            builder: (context, state, _) {
              final total = state.bookings.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.green100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${state.translate('total')} $total',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.green700)),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppTheme.slate100, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _tab(context.read<AppState>().translate('active'), true),
            _tab(context.read<AppState>().translate('completed'), false),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool isActive) {
    final selected = _showActive == isActive;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _showActive = isActive;
          _emptyAnim.reset();
          _emptyAnim.forward();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected
                  ? Theme.of(context).textTheme.bodyLarge!.color
                  : AppTheme.slate500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _emptyFade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.green100, AppTheme.green700.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _showActive ? LucideIcons.calendarX2 : LucideIcons.inbox,
                  color: AppTheme.green700,
                  size: 50,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _showActive ? context.read<AppState>().translate('noActiveBookings') : context.read<AppState>().translate('noPastBookings'),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _showActive
                    ? context.read<AppState>().translate('bookTractorHome')
                    : context.read<AppState>().translate('pastBookingsAppear'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.slate400, height: 1.6),
              ),
              if (_showActive) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<AppState>().setScreen('dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green700,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(LucideIcons.search, size: 18),
                  label: Text(context.read<AppState>().translate('browseEquipment'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Booking Card ────────────────────────────────────────────────────

class _AnimatedBookingCard extends StatefulWidget {
  final dynamic booking;
  final int index;
  final bool isActive;

  const _AnimatedBookingCard(
      {required this.booking, required this.index, required this.isActive});

  @override
  State<_AnimatedBookingCard> createState() => _AnimatedBookingCardState();
}

class _AnimatedBookingCardState extends State<_AnimatedBookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350 + widget.index * 60));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF3B82F6);
      case 'IN_PROGRESS':
        return AppTheme.green700;
      case 'REQUESTED':
        return const Color(0xFFF59E0B);
      case 'COMPLETED':
        return AppTheme.slate500;
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFEF4444);
      case 'PAYMENT_PENDING':
        return const Color(0xFF8B5CF6);
      default:
        return AppTheme.green700;
    }
  }

  String _statusLabel(AppState state, String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return state.translate('inProgress');
      case 'PAYMENT_PENDING':
        return state.translate('paymentDue');
      default:
        // Attempt to translate the status if key exists, otherwise format
        final key = status.toLowerCase();
        final translated = state.translate(key);
        return translated != key ? translated : status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final statusColor = _statusColor(booking.status);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.slate100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Top colored status bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            booking.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.green100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.agriculture,
                                  color: AppTheme.green700, size: 36),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.equipmentName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _statusLabel(context.read<AppState>(), booking.status),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.calendar,
                                      size: 13, color: AppTheme.slate400),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${booking.date}  ${booking.startTime}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppTheme.slate400),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin,
                                      size: 13, color: AppTheme.slate400),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.village,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppTheme.slate400),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${booking.amount}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.green700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    widget.isActive
                        ? _buildActiveActions(context, booking)
                        : _buildCompletedActions(context, booking),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveActions(BuildContext context, dynamic booking) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AppState>().setSelectedBooking(booking);
              context.read<AppState>().setScreen('tracking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green700,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.navigation, size: 16),
            label: Text(context.read<AppState>().translate('liveTrack'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, booking),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(context.read<AppState>().translate('cancel'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActions(BuildContext context, dynamic booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<AppState>().setSelectedBooking(booking);
              context.read<AppState>().setScreen('review');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppTheme.slate200),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.star, size: 16, color: AppTheme.slate500),
            label: Text(context.read<AppState>().translate('writeReview'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final activeEquipment =
                  context.read<AppState>().filteredEquipment;
              if (activeEquipment.isNotEmpty) {
                final eq = activeEquipment.firstWhere(
                    (e) => e.id == booking.equipmentId,
                    orElse: () => activeEquipment.first);
                context.read<AppState>().setSelectedEquipment(eq);
                context.read<AppState>().setScreen('booking-details');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green700,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: Text(context.read<AppState>().translate('reBook'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, dynamic booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle,
                  color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              context.read<AppState>().translate('cancelBookingQ'),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              context.read<AppState>().translate('cancelBookingSub'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.slate500, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.slate200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(context.read<AppState>().translate('keepIt'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      setState(() => booking.status = 'CANCELLED');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(context.read<AppState>().translate('cancel'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
