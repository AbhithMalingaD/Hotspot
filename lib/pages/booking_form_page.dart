import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  int    _selectedDate = 15;
  TimeOfDay _checkIn  = const TimeOfDay(hour: 9,  minute: 0);
  TimeOfDay _checkOut = const TimeOfDay(hour: 12, minute: 0);
  String _selectedPkg = 'p1';
  bool   _accepted    = false;

  static const _packages = [
    {'id': 'p1', 'name': 'Hot Desk',            'price': 500},
    {'id': 'p2', 'name': 'Private Meeting Room', 'price': 1500},
    {'id': 'p3', 'name': 'Board Room',           'price': 3500},
    {'id': 'p4', 'name': 'Event Space',          'price': 8000},
  ];

  int get _price => (_packages.firstWhere((p) => p['id'] == _selectedPkg)['price'] as int);

  double get _durationHours {
    final checkInMinutes = _checkIn.hour * 60 + _checkIn.minute;
    final checkOutMinutes = _checkOut.hour * 60 + _checkOut.minute;
    if (checkOutMinutes <= checkInMinutes) return 0;
    return (checkOutMinutes - checkInMinutes) / 60.0;
  }

  String get _durationFormatted {
    final hours = _durationHours;
    if (hours == 0) return '0 hours';
    if (hours == 1) return '1 hour';
    if (hours.floor() == hours) return '${hours.toInt()} hours';
    return '${hours.toStringAsFixed(1)} hours';
  }

  int get _total => (_price * _durationHours).round();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(children: [
        SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () =>
                      context.read<AppProvider>().closeBookingForm(),
                ),
                Expanded(
                  child: Text('Book a Space',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
                ),
                const SizedBox(width: 48),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.appAccent.withOpacity(0.20)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  context.watch<AppProvider>().bookingSpaceName,
                                  style: AppTextStyles.heading3.copyWith(color: AppTheme.textPrimary(context))),
                              Text(
                                'LKR $_price/hr',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.appAccent),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(
                        icon: Icons.calendar_today_rounded,
                        label: 'Select date'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 72,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (_, i) {
                          final date = 14 + i;
                          final sel = _selectedDate == date;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.appAccent : AppTheme.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel ? AppColors.appAccent : AppTheme.dividerColor(context),
                                ),
                                boxShadow: sel ? [BoxShadow(
                                  color: AppColors.appAccent.withOpacity(0.30),
                                  blurRadius: 15,
                                )] : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Mar', style: AppTextStyles.label),
                                  Text('$date',
                                      style: AppTextStyles.heading3
                                          .copyWith(fontSize: 18,
                                              color: sel ? Colors.white : AppTheme.textSecondary(context))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(
                        icon: Icons.access_time_rounded,
                        label: 'Select time'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _TimePicker(
                        label: 'Check-in',
                        time: _checkIn,
                        onPick: (t) => setState(() => _checkIn = t),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _TimePicker(
                        label: 'Check-out',
                        time: _checkOut,
                        onPick: (t) => setState(() => _checkOut = t),
                      )),
                    ]),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Duration: $_durationFormatted',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.appAccent,
                                    fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Select package',
                        style: AppTextStyles.heading3.copyWith(color: AppTheme.textPrimary(context))),
                    const SizedBox(height: 12),
                    ..._packages.map((p) {
                      final sel = _selectedPkg == p['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPkg = p['id'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.appAccent.withOpacity(0.10) : AppTheme.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel ? AppColors.appAccent : AppTheme.dividerColor(context),
                            ),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'] as String,
                                      style: AppTextStyles.body.copyWith(color: AppTheme.textPrimary(context))),
                                  Text('LKR ${p['price']}/hr',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.appAccent)),
                                ],
                              ),
                            ),
                            if (sel)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.appAccent, size: 20),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('LKR $_price × $_durationFormatted',
                                style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
                            Text('LKR $_total',
                                style: AppTextStyles.body.copyWith(color: AppTheme.textPrimary(context))),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Divider(color: AppTheme.dividerColor(context)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
                            Text('LKR $_total',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.appAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _accepted ? AppColors.appAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _accepted ? AppColors.appAccent : AppTheme.dividerColor(context),
                              ),
                            ),
                            child: _accepted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('I accept the cancellation policy',
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
                                const SizedBox(height: 4),
                                Text('Free cancellation up to 2 hours before check-in. After that, 50% fee applies.',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppTheme.bg(context), Colors.transparent],
              ),
            ),
            child: ElevatedButton(
              onPressed: _accepted ? () => context.read<AppProvider>().confirmBooking() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accepted ? AppColors.appAccent : AppTheme.surfaceVariant(context),
                disabledBackgroundColor: AppTheme.surfaceVariant(context),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Confirm Booking',
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: _accepted ? Colors.white : AppTheme.textSecondary(context))),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.appAccent2),
      const SizedBox(width: 8),
      Text(label,
          style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
    ]);
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;

  const _TimePicker({required this.label, required this.time, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final p = time.period == DayPeriod.am ? 'AM' : 'PM';
    final app = context.watch<AppProvider>();

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text('$h:$m $p',
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
          ],
        ),
      ),
    );
  }
}