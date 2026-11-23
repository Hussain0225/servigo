import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const BusBookingApp());

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFFEAEFF6); // cool paper grey
  static const cobalt = Color(0xFF1B3A8A); // primary / ticket backdrop
  static const busYellow = Color(0xFFF2B705); // accent (bus yellow)
  static const ink = Color(0xFF16213E); // main text
  static const muted = Color(0xFF6B7690); // secondary text
  static const success = Color(0xFF1F8A5B); // discount / success
  static const line = Color(0xFFD5DCEA); // dividers
}

String fmt(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

// ---------------------------------------------------------------------------
// Model + business logic
// ---------------------------------------------------------------------------
class Booking {
  final String name;
  final String from;
  final String to;
  final int seats;
  final double pricePerKm;

  const Booking({
    required this.name,
    required this.from,
    required this.to,
    required this.seats,
    required this.pricePerKm,
  });

  static const int discountThreshold = 5;
  static const double discountRate = 0.10;

  double get subtotal => seats * pricePerKm;
  bool get hasDiscount => seats >= discountThreshold;
  double get discount => hasDiscount ? subtotal * discountRate : 0;
  double get total => subtotal - discount;

  /// Console summary — same format as the assignment's expected output.
  String summary() => '''
========== BUS BOOKING ==========

Passenger: $name
From: $from
To: $to
Ticket Price: ${fmt(pricePerKm)}

Subtotal: ${fmt(subtotal)}
Discount: ${fmt(discount)}
Final Amount: ${fmt(total)}

Booking Successful!
=================================''';
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
class BusBookingApp extends StatelessWidget {
  const BusBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cobalt,
          primary: AppColors.cobalt,
          secondary: AppColors.busYellow,
        ),
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const BookingScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Screen 1: Booking form
// ---------------------------------------------------------------------------
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _seats = 1;

  double get _price => double.tryParse(_priceCtrl.text.trim()) ?? 0;

  Booking get _preview => Booking(
        name: _nameCtrl.text.trim(),
        from: _fromCtrl.text.trim(),
        to: _toCtrl.text.trim(),
        seats: _seats,
        pricePerKm: _price,
      );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _swapCities() {
    final temp = _fromCtrl.text;
    _fromCtrl.text = _toCtrl.text;
    _toCtrl.text = temp;
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final booking = _preview;
    debugPrint(booking.summary()); // console output like the assignment
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
    );
  }

  InputDecoration _decoration(String label, IconData icon, {String? prefix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.cobalt),
      prefixText: prefix,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: border(AppColors.line),
      focusedBorder: border(AppColors.cobalt, 2),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 2),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final seatsToDiscount = Booking.discountThreshold - _seats;

    return Scaffold(
      body: Column(
        children: [
          _Header(topPadding: MediaQuery.of(context).padding.top),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Passenger',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration:
                          _decoration('Passenger name', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter the passenger name'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    const Text('Route',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _fromCtrl,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: _decoration(
                                    'From', Icons.trip_origin_rounded),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Enter the source city'
                                        : null,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _toCtrl,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration:
                                    _decoration('To', Icons.location_on_outlined),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Enter the destination city';
                                  }
                                  if (v.trim().toLowerCase() ==
                                      _fromCtrl.text.trim().toLowerCase()) {
                                    return 'Destination must differ from source';
                                  }
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 34),
                          child: IconButton.filledTonal(
                            tooltip: 'Swap cities',
                            onPressed: _swapCities,
                            icon: const Icon(Icons.swap_vert_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Ride in Km',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                    const SizedBox(height: 10),
                    _SeatStepper(
                      seats: _seats,
                      onChanged: (v) => setState(() => _seats = v),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: seatsToDiscount > 0
                          ? Text(
                              seatsToDiscount == 1
                                  ? 'Add 1 more seat to get 10% off'
                                  : 'Add $seatsToDiscount more seats to get 10% off',
                              key: const ValueKey('hint'),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 13),
                            )
                          : Row(
                              key: const ValueKey('applied'),
                              children: const [
                                Icon(Icons.check_circle,
                                    size: 16, color: AppColors.success),
                                SizedBox(width: 6),
                                Text('10% group discount applied',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                          'Price per Km', Icons.confirmation_number_outlined,
                          prefix: '₹ '),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) {
                          return 'Enter a price greater than 0';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BottomBar(
            total: preview.total,
            hasDiscount: preview.hasDiscount,
            hasPrice: _price > 0,
            onBook: _submit,
          ),
        ],
      ),
    );
  }
}

// --- Header ---------------------------------------------------------------
class _Header extends StatelessWidget {
  final double topPadding;
  const _Header({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.cobalt,
        border: Border(
          bottom: BorderSide(color: AppColors.busYellow, width: 5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.busYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_bus_filled_rounded,
                color: AppColors.ink, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Book a bus ticket',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Fill in the trip details to see your fare',
                    style: TextStyle(color: Color(0xFFC9D4F0), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Seat stepper ---------------------------------------------------------
class _SeatStepper extends StatelessWidget {
  final int seats;
  final ValueChanged<int> onChanged;
  const _SeatStepper({required this.seats, required this.onChanged});

  static const int maxSeats = 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_seat_outlined, color: AppColors.cobalt),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Number of Kilometers',
                style: TextStyle(fontSize: 16, color: AppColors.ink)),
          ),
          IconButton.outlined(
            tooltip: 'Remove a seat',
            onPressed: seats > 1 ? () => onChanged(seats - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 44,
            child: Text('$seats',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ),
          IconButton.filled(
            tooltip: 'Add a seat',
            onPressed: seats < maxSeats ? () => onChanged(seats + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

// --- Bottom bar -----------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final double total;
  final bool hasDiscount;
  final bool hasPrice;
  final VoidCallback onBook;

  const _BottomBar({
    required this.total,
    required this.hasDiscount,
    required this.hasPrice,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total fare',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(hasPrice ? '₹ ${fmt(total)}' : '—',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  if (hasDiscount && hasPrice)
                    const Text('Includes 10% discount',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            FilledButton(
              onPressed: onBook,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.busYellow,
                foregroundColor: AppColors.ink,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              child: const Text('Create a ride'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Screen 2: Ticket (booking summary)
// ---------------------------------------------------------------------------
class TicketScreen extends StatelessWidget {
  final Booking booking;
  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cobalt,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                // Success badge
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.elasticOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Booking Successful!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 22),
                _TicketCard(booking: booking),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.busYellow,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('Book another ticket'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Booking booking;
  const _TicketCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          // --- Top: passenger + route
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NAME',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 2),
                Text(booking.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _City(label: 'From', name: booking.from),
                    const Expanded(child: _RouteLine()),
                    _City(label: 'To', name: booking.to, alignEnd: true),
                  ],
                ),
              ],
            ),
          ),
          const _TicketDivider(),
          // --- Bottom: fare breakdown
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              children: [
                _Row('Seats', '${booking.seats}'),
                _Row('Ticket price', '₹ ${fmt(booking.pricePerKm)}'),
                _Row('Subtotal', '₹ ${fmt(booking.subtotal)}'),
                _Row(
                  booking.hasDiscount ? 'Discount (10%)' : 'Discount',
                  booking.hasDiscount
                      ? '- ₹ ${fmt(booking.discount)}'
                      : '₹ 0',
                  valueColor:
                      booking.hasDiscount ? AppColors.success : null,
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.busYellow.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Final amount',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
                      Text('₹ ${fmt(booking.total)}',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink)),
                    ],
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

class _City extends StatelessWidget {
  final String label;
  final String name;
  final bool alignEnd;
  const _City({required this.label, required this.name, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 2),
          Text(name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cobalt)),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.cobalt),
          Expanded(child: Container(height: 2, color: AppColors.line)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.directions_bus_rounded,
                size: 22, color: AppColors.cobalt),
          ),
          Expanded(child: Container(height: 2, color: AppColors.line)),
          const Icon(Icons.location_on, size: 16, color: AppColors.cobalt),
        ],
      ),
    );
  }
}

/// Dashed divider with half-circle cut-outs on both edges (ticket perforation).
class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    const notch = 24.0;
    return SizedBox(
      height: notch,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: notch),
              child: LayoutBuilder(
                builder: (context, c) {
                  final dashes = (c.maxWidth / 10).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      dashes,
                      (_) => Container(
                          width: 5, height: 2, color: AppColors.line),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: -notch / 2,
            top: 0,
            child: Container(
              width: notch,
              height: notch,
              decoration: const BoxDecoration(
                  color: AppColors.cobalt, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -notch / 2,
            top: 0,
            child: Container(
              width: notch,
              height: notch,
              decoration: const BoxDecoration(
                  color: AppColors.cobalt, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 15)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.ink)),
        ],
      ),
    );
  }
}