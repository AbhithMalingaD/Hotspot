import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import 'scan_qr_code_page.dart';
import 'booking_requests_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String? _expandedGlance;
  int? _expandedBooking;
  int? _expandedPayment;
  int? _expandedCustomer;
  int? _editingPackage;
  String? _toast;
  bool _settingsOpen = false;
  String? _availBreakdown;
  String? _revenueCalPkg;
  DateTime _revMonth = DateTime(2026, 3);
  DateTime? _revSelected;
  String? _heatTooltip;
  int? _heatRow, _heatCol;
  bool _addPkgOpen = false;
  String? _announcementMode;

  final List<Map<String, dynamic>> _amenities = [
    {'id': 'wifi', 'label': 'WiFi', 'on': true, 'icon': Icons.wifi_rounded},
    {'id': 'coffee', 'label': 'Coffee', 'on': true, 'icon': Icons.coffee_rounded},
    {'id': 'ac', 'label': 'Air con', 'on': true, 'icon': Icons.ac_unit_rounded},
    {'id': 'parking', 'label': 'Parking', 'on': false, 'icon': Icons.local_parking_rounded},
    {'id': 'print', 'label': 'Printing', 'on': false, 'icon': Icons.print_rounded},
    {'id': 'access', 'label': '24hr access', 'on': true, 'icon': Icons.vpn_key_rounded},
  ];

  void _showToast(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (_settingsOpen) {
      return _AdminSettingsPage(onBack: () => setState(() => _settingsOpen = false));
    }

    return Scaffold(
      backgroundColor: app.adminBg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: app.adminAccent.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: app.adminAccent2.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            children: [
              _buildHeader(app),
              Expanded(child: _buildBody(app)),
            ],
          ),
          if (_toast != null) _buildToast(app),
          if (_availBreakdown != null)
            _buildOverlay(_AvailDialog(
              slot: _availBreakdown!,
              onClose: () => setState(() => _availBreakdown = null),
            )),
          if (_revenueCalPkg != null)
            _buildOverlay(_RevCalDialog(
              pkg: _revenueCalPkg!,
              month: _revMonth,
              selected: _revSelected,
              onMonth: (m) => setState(() => _revMonth = m),
              onDay: (d) => setState(() => _revSelected = d),
              onClose: () => setState(() => _revenueCalPkg = null),
            )),
          if (_heatTooltip != null)
            _buildOverlay(_HeatDialog(
              label: _heatTooltip!,
              onClose: () => setState(() {
                _heatTooltip = null;
                _heatRow = null;
                _heatCol = null;
              }),
            )),
          if (_addPkgOpen)
            _buildOverlay(_AddPkgDialog(
              onClose: () => setState(() => _addPkgOpen = false),
              onSave: (n, t, p, c) {
                setState(() => _addPkgOpen = false);
                _showToast('Package "$n" added');
              },
            )),
          if (_announcementMode != null)
            _buildOverlay(_AnnounceDialog(
              mode: _announcementMode!,
              onClose: () => setState(() => _announcementMode = null),
              onPost: (msg) {
                setState(() => _announcementMode = null);
                _showToast(msg);
              },
            )),
          if (app.isScanQROpen) const ScanQRCodePage(),
          if (app.isBookingRequestsOpen) const BookingRequestsPage(),
        ],
      ),
    );
  }

  Widget _buildHeader(AppProvider app) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
        decoration: BoxDecoration(
          color: app.adminCard.withOpacity(0.50),
          border: Border(bottom: BorderSide(color: app.adminBorder.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Space admin', style: AppTextStyles.label.copyWith(color: app.adminAccent2)),
                  Text(
                    'Urban Hub · Colombo 03',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: app.adminTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconBtn(
              icon: Icons.crop_free_rounded,
              color: app.adminAccent,
              badge: false,
              onTap: () => app.setScanQROpen(true),
            ),
            const SizedBox(width: 8),
            _HeaderIconBtn(
              icon: Icons.inbox_rounded,
              color: app.adminAccent2,
              badge: true,
              onTap: () => app.setBookingRequestsOpen(true),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _settingsOpen = true),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: app.adminAccent.withOpacity(0.20),
                  border: Border.all(color: app.adminAccent.withOpacity(0.50)),
                ),
                child: Center(
                  child: Text(
                    'UH',
                    style: TextStyle(color: app.adminAccent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppProvider app) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionTitle('Today at a glance'),
              const SizedBox(height: 10),
              _GlanceGrid(
                expanded: _expandedGlance,
                onExpand: (id) => setState(() => _expandedGlance = _expandedGlance == id ? null : id),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Live bookings & QR log'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _BookingsList(
                  expanded: _expandedBooking,
                  onExpand: (i) => setState(() => _expandedBooking = _expandedBooking == i ? null : i),
                  onToast: _showToast,
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Pending payments'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _PaymentsList(
                  expanded: _expandedPayment,
                  onExpand: (i) => setState(() => _expandedPayment = _expandedPayment == i ? null : i),
                  onToast: _showToast,
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Availability this week'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _AvailSection(
                  onSlotTap: (s) => setState(() => _availBreakdown = s),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Packages & pricing'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _PackagesList(
                  editing: _editingPackage,
                  onEdit: (i) => setState(() => _editingPackage = _editingPackage == i ? null : i),
                  onToast: _showToast,
                  onAdd: () => setState(() => _addPkgOpen = true),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Live amenities'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _AmenitiesSection(
                  amenities: _amenities,
                  onToggle: (id) {
                    setState(() {
                      final idx = _amenities.indexWhere((a) => a['id'] == id);
                      if (idx != -1) {
                        _amenities[idx] = {
                          ..._amenities[idx],
                          'on': !(_amenities[idx]['on'] as bool),
                        };
                      }
                    });
                  },
                  onSave: () => _showToast('Amenities updated — guests can see changes'),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Revenue by package'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _RevenueSection(
                  onPkgTap: (p) => setState(() {
                    _revenueCalPkg = p;
                    _revSelected = null;
                    _revMonth = DateTime(2026, 3);
                  }),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Peak hour heatmap'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _PeakHeatmap(
                  hRow: _heatRow,
                  hCol: _heatCol,
                  onCell: (r, c, l) => setState(() {
                    _heatRow = r;
                    _heatCol = c;
                    _heatTooltip = l;
                  }),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Post announcement'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _AnnounceSection(
                  onMode: (m) => setState(() => _announcementMode = m),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Top customers (loyalty)'),
              const SizedBox(height: 10),
              _AdminCard(
                child: _CustomersList(
                  expanded: _expandedCustomer,
                  onExpand: (i) => setState(() => _expandedCustomer = _expandedCustomer == i ? null : i),
                ),
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildToast(AppProvider app) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: app.adminCard.withOpacity(0.95),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: app.adminAccent.withOpacity(0.50)),
            boxShadow: [BoxShadow(color: app.adminAccent.withOpacity(0.30), blurRadius: 20)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.adminAccent, size: 18),
              const SizedBox(width: 8),
              Text(_toast!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(Widget child) {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(child: child),
    );
  }
}

// ============================================================================
// HELPER WIDGETS (theme‑aware)
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: app.adminAccent2.withOpacity(0.80),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final Widget child;
  const _AdminCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: app.adminBorder.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool badge;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.color,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.20)),
            child: Icon(icon, color: color, size: 16),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: app.adminBg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Detail cell with dynamic colours ─────────────────────────────────────────
class _DC extends StatelessWidget {
  final String l, v;
  final bool acc;
  const _DC(this.l, this.v, {this.acc = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l, style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
        Text(
          v,
          style: AppTextStyles.bodySmall.copyWith(
            color: acc ? app.adminAccent2 : app.adminTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// GLANCE GRID – with sibling blur/scale
// ============================================================================

class _GlanceGrid extends StatelessWidget {
  final String? expanded;
  final ValueChanged<String> onExpand;
  const _GlanceGrid({required this.expanded, required this.onExpand});

  static const _cards = [
    {
      'id': 'sessions',
      'icon': Icons.people_outline_rounded,
      'title': 'Live sessions',
      'val': '4',
      'sub': 'of 10 seats',
      'color': AppColors.adminAccent,
      'detail': [
        {'n': 'Kasun Perera', 't': 'Hot Desk', 'time': '2:00 PM'},
        {'n': 'Amal Fernando', 't': 'Board Room', 'time': '9:00 AM'},
      ],
    },
    {
      'id': 'qr',
      'icon': Icons.qr_code_2_rounded,
      'title': 'Today QR scans',
      'val': '7',
      'sub': '6 valid · 1 invalid',
      'color': AppColors.adminAccent2,
      'detail': [
        {'n': 'Kasun Perera', 't': 'Valid', 'time': '2:02 PM'},
        {'n': 'Unknown', 't': 'Invalid – Expired', 'time': '10:30 AM'},
      ],
    },
    {
      'id': 'pay',
      'icon': Icons.credit_card_outlined,
      'title': 'Pending payment',
      'val': '2',
      'sub': 'LKR 3,000',
      'color': AppColors.orange400,
      'detail': [
        {'n': 'Nimasha De Silva', 't': 'LKR 1,500', 'time': 'Due Today'},
        {'n': 'Roshan J.', 't': 'LKR 1,500', 'time': 'Due Mar 16'},
      ],
    },
    {
      'id': 'rev',
      'icon': Icons.trending_up_rounded,
      'title': 'This month',
      'val': 'LKR 84,500',
      'sub': '+12% vs last month',
      'color': Colors.white,
      'detail': [
        {'n': 'Week 1', 't': 'LKR 22,000', 'time': 'Mar 1-7'},
        {'n': 'Week 2', 't': 'LKR 18,500', 'time': 'Mar 8-14'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isExpanded = expanded != null;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _cards.length,
          itemBuilder: (_, i) {
            final c = _cards[i];
            final id = c['id'] as String;
            final isThisExpanded = expanded == id;
            final shouldDim = isExpanded && !isThisExpanded;

            final double scale = shouldDim ? 0.95 : 1.0;
            final double opacity = shouldDim ? 0.5 : 1.0;
            final double saturation = shouldDim ? 0.3 : 1.0;

            final cardColor = c['color'] as Color;
            return GestureDetector(
              onTap: () => onExpand(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..scale(scale),
                child: Opacity(
                  opacity: opacity,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(_saturationMatrix(saturation)),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isThisExpanded ? Colors.white.withOpacity(0.08) : app.adminCard.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isThisExpanded ? cardColor.withOpacity(0.50) : app.adminBorder.withOpacity(0.3),
                        ),
                        boxShadow: isThisExpanded ? [BoxShadow(color: cardColor.withOpacity(0.20), blurRadius: 20)] : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(c['icon'] as IconData, size: 14, color: AppColors.grey400),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  c['title'] as String,
                                  style: AppTextStyles.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(isThisExpanded ? Icons.expand_less : Icons.expand_more, size: 14, color: AppColors.grey500),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            c['val'] as String,
                            style: AppTextStyles.heading2.copyWith(color: cardColor, fontSize: isThisExpanded ? 26 : 22),
                          ),
                          Text(c['sub'] as String, style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (expanded != null) ...[
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final card = _cards.firstWhere((c) => c['id'] == expanded, orElse: () => _cards[0]);
              final details = card['detail'] as List;
              final accent = card['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: app.adminCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Column(
                  children: details.map<Widget>((d) {
                    final item = d as Map;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['n'] as String,
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item['t'] as String, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                              Text(item['time'] as String, style: AppTextStyles.label.copyWith(color: accent)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  static List<double> _saturationMatrix(double saturation) {
    final r = 1 - saturation;
    return [
      0.2126 * r + saturation, 0.7152 * r, 0.0722 * r, 0, 0,
      0.2126 * r, 0.7152 * r + saturation, 0.0722 * r, 0, 0,
      0.2126 * r, 0.7152 * r, 0.0722 * r + saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }
}

// ============================================================================
// BOOKINGS LIST – with reject form
// ============================================================================

class _BookingsList extends StatelessWidget {
  final int? expanded;
  final ValueChanged<int> onExpand;
  final ValueChanged<String> onToast;
  const _BookingsList({required this.expanded, required this.onExpand, required this.onToast});

  static const _items = [
    {
      'name': 'Kasun Perera',
      'type': 'Hot Desk',
      'desc': 'Check-in 2:00 PM · QR scanned',
      'status': 'Active',
      'phone': '+94 77 123 4567',
      'amount': 'LKR 1,500',
      'checkIn': '2:00 PM',
      'checkOut': '5:00 PM',
      'duration': '3 hours',
      'qr': 'Scanned at 2:02 PM',
    },
    {
      'name': 'Nimasha De Silva',
      'type': 'Pvt Room',
      'desc': 'Booked 4:00 PM · QR not yet scanned',
      'status': 'Pending',
      'phone': '+94 77 456 7890',
      'amount': 'LKR 1,500',
      'checkIn': '4:00 PM',
      'checkOut': '6:00 PM',
      'duration': '2 hours',
      'qr': 'Not yet scanned',
    },
    {
      'name': 'Unknown',
      'type': 'Hot Desk',
      'desc': '10:30 AM · QR token expired',
      'status': 'Invalid QR',
      'phone': '—',
      'amount': '—',
      'checkIn': '10:30 AM',
      'checkOut': '—',
      'duration': '—',
      'qr': 'Token expired',
    },
    {
      'name': 'Amal Fernando',
      'type': 'Board Room',
      'desc': '9:00 AM – 12:00 PM · Checked out',
      'status': 'Done',
      'phone': '+94 71 234 5678',
      'amount': 'LKR 7,000',
      'checkIn': '9:00 AM',
      'checkOut': '12:00 PM',
      'duration': '3 hours',
      'qr': 'Checked out',
    },
  ];

  Color _sc(String s) {
    switch (s) {
      case 'Active':
        return AppColors.adminAccent;
      case 'Pending':
        return AppColors.orange400;
      case 'Invalid QR':
        return AppColors.red400;
      default:
        return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: _items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final isExp = expanded == i;
        final c = _sc(item['status']!);
        final isPending = item['status'] == 'Pending';
        return GestureDetector(
          onTap: () => onExpand(i),
          child: Container(
            decoration: BoxDecoration(
              color: isExp ? Colors.white.withOpacity(0.04) : Colors.transparent,
              border: Border(bottom: BorderSide(color: app.adminBorder.withOpacity(0.5))),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['name']} — ${item['type']}',
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary),
                            ),
                            Text(item['desc']!, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: c.withOpacity(0.30)),
                        ),
                        child: Text(item['status']!, style: AppTextStyles.label.copyWith(color: c)),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: isExp ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey500, size: 16),
                      ),
                    ],
                  ),
                ),
                if (isExp)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: app.adminCard.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: app.adminBorder.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.2,
                            children: [
                              _DC('Phone', item['phone']!),
                              _DC('Amount', item['amount']!, acc: true),
                              _DC('Check-in', item['checkIn']!),
                              _DC('Check-out', item['checkOut']!),
                              _DC('Duration', item['duration']!),
                              _DC('QR Status', item['qr']!, acc: true),
                            ],
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 10),
                            _RejectForm(
                              onConfirm: () => onToast('Booking confirmed — customer notified'),
                              onReject: (reason, notify) {
                                onToast('Booking rejected: ${reason.isNotEmpty ? reason : 'No reason provided'}');
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Reject form widget (animated replacement for Confirm/Reject buttons) ───
class _RejectForm extends StatefulWidget {
  final VoidCallback onConfirm;
  final Function(String reason, bool notifyCustomer) onReject;

  const _RejectForm({required this.onConfirm, required this.onReject});

  @override
  State<_RejectForm> createState() => _RejectFormState();
}

class _RejectFormState extends State<_RejectForm> {
  bool _showRejectForm = false;
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _notifyCustomer = true;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (!_showRejectForm) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Confirm', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _showRejectForm = true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.red400.withOpacity(0.50)),
                foregroundColor: AppColors.red400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reject'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: _reasonCtrl,
          style: AppTextStyles.bodySmall.copyWith(color: app.adminTextPrimary),
          decoration: InputDecoration(
            hintText: 'Reason for rejection (optional)',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary),
            filled: true,
            fillColor: app.adminCard.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: app.adminBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: app.adminBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.adminAccent),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _notifyCustomer,
              onChanged: (v) => setState(() => _notifyCustomer = v ?? true),
              activeColor: AppColors.adminAccent,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text('Notify customer', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showRejectForm = false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: app.adminBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancel', style: AppTextStyles.body.copyWith(color: app.adminTextSecondary)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.onReject(_reasonCtrl.text, _notifyCustomer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Confirm Reject', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// PAYMENTS LIST
// ============================================================================

class _PaymentsList extends StatelessWidget {
  final int? expanded;
  final ValueChanged<int> onExpand;
  final ValueChanged<String> onToast;
  const _PaymentsList({required this.expanded, required this.onExpand, required this.onToast});

  static const _items = [
    {
      'name': 'Nimasha De Silva',
      'desc': 'Private Room · LKR 1,500 · Due today',
      'phone': '+94 77 456 7890',
      'booking': 'Mar 14',
      'days': '1 day',
      'lastDay': 'Mar 16',
      'method': 'Cash / Card pending',
      'amt': 'LKR 1,500',
    },
    {
      'name': 'Roshan Jayawardena',
      'desc': 'Hot Desk · LKR 1,500 · Due Mar 16',
      'phone': '+94 71 987 6543',
      'booking': 'Mar 13',
      'days': '3 days',
      'lastDay': 'Mar 18',
      'method': 'Cash / Card pending',
      'amt': 'LKR 1,500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: _items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final isExp = expanded == i;
        return GestureDetector(
          onTap: () => onExpand(i),
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: app.adminBorder.withOpacity(0.5)))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name']!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
                            Text(item['desc']!, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.orange400.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.orange400.withOpacity(0.30)),
                        ),
                        child: Text('Awaiting', style: AppTextStyles.label.copyWith(color: AppColors.orange400)),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: isExp ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey500, size: 16),
                      ),
                    ],
                  ),
                ),
                if (isExp)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: app.adminCard.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: app.adminBorder.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.2,
                            children: [
                              _DC('Phone', item['phone']!),
                              _DC('Booking Date', item['booking']!),
                              _DC('Days Pending', item['days']!, acc: true),
                              _DC('Last Day', item['lastDay']!, acc: true),
                              _DC('Method', item['method']!),
                              _DC('Amount', item['amt']!),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => onToast('Reminder sent to ${item['name']}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: app.adminAccent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('Send reminder', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// AVAILABILITY SECTION (unchanged, but uses app.adminCard)
// ============================================================================

class _AvailSection extends StatelessWidget {
  final ValueChanged<String> onSlotTap;
  const _AvailSection({required this.onSlotTap});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _am = [
    {'t': 0, 'l': 'Open'},
    {'t': 2, 'l': 'Full'},
    {'t': 1, 'l': '5/10'},
    {'t': 0, 'l': 'Open'},
    {'t': 2, 'l': 'Full'},
    {'t': 1, 'l': '3/10'},
  ];
  static const _pm = [
    {'t': 1, 'l': '4/10'},
    {'t': 0, 'l': 'Open'},
    {'t': 2, 'l': 'Full'},
    {'t': 1, 'l': '7/10'},
    {'t': 0, 'l': 'Open'},
    {'t': 1, 'l': '2/10'},
  ];

  Color _bg(int t, BuildContext context) {
    if (t == 0) return AppColors.adminAccent.withOpacity(0.20);
    if (t == 1) return AppColors.orange400.withOpacity(0.22);
    if (t == 2) return AppColors.red400.withOpacity(0.22);
    return context.watch<AppProvider>().adminCard.withOpacity(0.5);
  }

  Color _tx(int t) {
    if (t == 0) return AppColors.adminAccent;
    if (t == 1) return AppColors.orange400;
    if (t == 2) return AppColors.red400;
    return AppColors.grey500;
  }

  Widget _row(String label, List<Map<String, dynamic>> data, BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 38, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400))),
        ...data.asMap().entries.map((e) => Expanded(
              child: GestureDetector(
                onTap: () => onSlotTap('${_days[e.key]} $label'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _bg(e.value['t'] as int, context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.grey500.withOpacity(0.3)),
                  ),
                  child: Text(
                    e.value['l'] as String,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(color: _tx(e.value['t'] as int), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 38),
              ..._days.map((d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(color: AppColors.grey400),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          _row('AM', List<Map<String, dynamic>>.from(_am), context),
          const SizedBox(height: 8),
          _row('PM', List<Map<String, dynamic>>.from(_pm), context),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            children: [
              _AL(AppColors.adminAccent, 'Open'),
              _AL(AppColors.orange400, 'Partial'),
              _AL(AppColors.red400, 'Full'),
              _AL(AppColors.grey500, 'Closed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AL extends StatelessWidget {
  final Color c;
  final String l;
  const _AL(this.c, this.l);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(l, style: AppTextStyles.label.copyWith(color: AppColors.grey400)),
      ],
    );
  }
}

// ============================================================================
// AVAILABILITY DIALOG – full width + theme‑aware
// ============================================================================

class _AvailDialog extends StatelessWidget {
  final String slot;
  final VoidCallback onClose;
  const _AvailDialog({required this.slot, required this.onClose});

  static const _slots = [
    {'time': '8:00 – 9:30 AM', 'booked': true, 'info': 'Booked (Kasun P, Hot Desk)'},
    {'time': '9:30 – 10:00 AM', 'booked': false, 'info': 'Available'},
    {'time': '10:00 – 11:00 AM', 'booked': true, 'info': 'Booked (Nimasha D, Hot Desk)'},
    {'time': '11:00 – 12:00 PM', 'booked': false, 'info': 'Available'},
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: app.adminAccent.withOpacity(0.20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$slot Breakdown',
                  style: AppTextStyles.heading3.copyWith(fontSize: 18, color: app.adminTextPrimary),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded, color: AppColors.grey400, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._slots.map((s) {
            final b = s['booked'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: b ? AppColors.red400.withOpacity(0.12) : app.adminAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: b ? AppColors.red400.withOpacity(0.25) : app.adminAccent.withOpacity(0.20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['time'] as String,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['info'] as String,
                    style: AppTextStyles.bodySmall.copyWith(color: b ? AppColors.red400 : app.adminAccent),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// PACKAGES LIST
// ============================================================================

class _PackagesList extends StatelessWidget {
  final int? editing;
  final ValueChanged<int> onEdit;
  final ValueChanged<String> onToast;
  final VoidCallback onAdd;
  const _PackagesList({
    required this.editing,
    required this.onEdit,
    required this.onToast,
    required this.onAdd,
  });

  static final List<Map<String, String>> _pkgs = [
    {'name': 'Hot Desk', 'price': 'LKR 500 / hr', 'cap': '8 seats'},
    {'name': 'Private Meeting Room', 'price': 'LKR 1,500 / hr', 'cap': '1 room'},
    {'name': 'Board Room', 'price': 'LKR 3,500 / hr', 'cap': '1 room'},
    {'name': 'Event Space', 'price': 'LKR 8,000 / hr', 'cap': '50 cap.'},
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: [
        ..._pkgs.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final isEd = editing == i;
          return GestureDetector(
            onTap: () => onEdit(i),
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: app.adminBorder.withOpacity(0.5)))),
              padding: const EdgeInsets.all(14),
              child: isEd
                  ? _PackageEditForm(name: p['name']!, onSave: () => onToast('${p['name']} updated'), onCancel: () => onEdit(i))
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['name']!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
                              Text(p['price']!, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: app.adminCard.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: app.adminBorder.withOpacity(0.5)),
                          ),
                          child: Text(p['cap']!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
                        ),
                      ],
                    ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(14),
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: app.adminAccent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: app.adminAccent.withOpacity(0.30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: AppColors.adminAccent, size: 18),
                  const SizedBox(width: 6),
                  Text('Add New Package', style: AppTextStyles.body.copyWith(color: app.adminAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageEditForm extends StatelessWidget {
  final String name;
  final VoidCallback onSave, onCancel;
  const _PackageEditForm({required this.name, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: [
        Text('Edit $name', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: _AdminTextField(hint: 'Price')),
            SizedBox(width: 10),
            Expanded(child: _AdminTextField(hint: 'Capacity')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: app.adminAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Save', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: app.adminBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancel', style: AppTextStyles.body.copyWith(color: app.adminTextSecondary)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminTextField extends StatelessWidget {
  final String hint;
  const _AdminTextField({required this.hint});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return TextField(
      style: AppTextStyles.bodySmall.copyWith(color: app.adminTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary),
        filled: true,
        fillColor: app.adminCard.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: app.adminAccent.withOpacity(0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: app.adminAccent.withOpacity(0.30)),
        ),
      ),
    );
  }
}

// ============================================================================
// ADD PACKAGE DIALOG
// ============================================================================

class _AddPkgDialog extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String, String, String, String) onSave;
  const _AddPkgDialog({required this.onClose, required this.onSave});

  @override
  State<_AddPkgDialog> createState() => _AddPkgDialogState();
}

class _AddPkgDialogState extends State<_AddPkgDialog> {
  final _n = TextEditingController();
  final _p = TextEditingController(text: '500');
  final _c = TextEditingController(text: '1 seat');
  String _type = 'Hot Desk';
  static const _types = ['Hot Desk', 'Private Office', 'Meeting Room', 'Event Space'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: app.adminAccent.withOpacity(0.20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Add New Package', style: AppTextStyles.heading3.copyWith(fontSize: 18, color: app.adminTextPrimary)),
              ),
              GestureDetector(onTap: widget.onClose, child: const Icon(Icons.close_rounded, color: AppColors.grey400, size: 20)),
            ],
          ),
          const SizedBox(height: 18),
          Text('Package Name', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
          const SizedBox(height: 6),
          _DF(ctrl: _n, hint: 'e.g. Dedicated Desk'),
          const SizedBox(height: 14),
          Text('Space Type', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: app.adminCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: app.adminAccent.withOpacity(0.25)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                dropdownColor: app.adminCard,
                style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey400),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price/hr (LKR)', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                    const SizedBox(height: 6),
                    _DF(ctrl: _p, hint: '500', kt: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Capacity', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                    const SizedBox(height: 6),
                    _DF(ctrl: _c, hint: '1 seat'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_n.text, _type, _p.text, _c.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: app.adminAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Save Package', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType kt;
  const _DF({required this.ctrl, required this.hint, this.kt = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return TextField(
      controller: ctrl,
      keyboardType: kt,
      style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: app.adminTextSecondary),
        filled: true,
        fillColor: app.adminCard.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: app.adminAccent.withOpacity(0.20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: app.adminAccent.withOpacity(0.20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.adminAccent),
        ),
      ),
    );
  }
}

// ============================================================================
// AMENITIES SECTION (with timestamp)
// ============================================================================

class _AmenitiesSection extends StatefulWidget {
  final List<Map<String, dynamic>> amenities;
  final ValueChanged<String> onToggle;
  final VoidCallback onSave;

  const _AmenitiesSection({
    required this.amenities,
    required this.onToggle,
    required this.onSave,
  });

  @override
  State<_AmenitiesSection> createState() => _AmenitiesSectionState();
}

class _AmenitiesSectionState extends State<_AmenitiesSection> {
  DateTime? _lastSaved;

  void _handleSave() {
    setState(() => _lastSaved = DateTime.now());
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            itemCount: widget.amenities.length,
            itemBuilder: (_, i) {
              final a = widget.amenities[i];
              final on = a['on'] as bool;
              return GestureDetector(
                onTap: () => widget.onToggle(a['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? app.adminAccent.withOpacity(0.10) : app.adminCard.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: on ? app.adminAccent.withOpacity(0.30) : app.adminBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(a['icon'] as IconData, size: 14, color: on ? app.adminAccent : AppColors.grey500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a['label'] as String,
                          style: AppTextStyles.label.copyWith(color: on ? Colors.white : app.adminTextSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 16,
                        decoration: BoxDecoration(
                          color: on ? app.adminAccent : app.adminBorder.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 150),
                          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          if (_lastSaved != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.save_alt_rounded, size: 12, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  'Last saved: ${_formatTimestamp(_lastSaved!)}',
                  style: AppTextStyles.label.copyWith(color: app.adminTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: app.adminAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Save & Publish Changes', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (time.isAfter(today)) {
      return 'Today at ${_formatTime(time)}';
    } else if (time.isAfter(yesterday)) {
      return 'Yesterday at ${_formatTime(time)}';
    } else {
      return '${time.day}/${time.month}/${time.year} at ${_formatTime(time)}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }
}

// ============================================================================
// REVENUE SECTION – with month selector (no calendar icons)
// ============================================================================

class _RevenueSection extends StatefulWidget {
  final ValueChanged<String> onPkgTap;
  const _RevenueSection({required this.onPkgTap});

  @override
  State<_RevenueSection> createState() => _RevenueSectionState();
}

class _RevenueSectionState extends State<_RevenueSection> {
  DateTime _currentMonth = DateTime.now();

  static const _items = [
    {'label': 'Hot Desk', 'value': 'LKR 42k', 'pct': 0.75, 'color': AppColors.adminAccent2},
    {'label': 'Pvt Room', 'value': 'LKR 24k', 'pct': 0.45, 'color': AppColors.adminAccent},
    {'label': 'Board Room', 'value': 'LKR 14k', 'pct': 0.25, 'color': Color(0xFFA78BFA)},
    {'label': 'Events', 'value': 'LKR 4.5k', 'pct': 0.10, 'color': AppColors.orange400},
  ];

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final monthName = _getMonthName(_currentMonth.month);
    final year = _currentMonth.year;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left, color: AppColors.grey400, size: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '$monthName $year',
                style: AppTextStyles.heading3.copyWith(fontSize: 16, color: app.adminTextPrimary),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right, color: AppColors.grey400, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          ..._items.map((item) => GestureDetector(
            onTap: () => widget.onPkgTap(item['label'] as String),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 68,
                    child: Text(
                      item['label'] as String,
                      style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: item['pct'] as double,
                        backgroundColor: app.adminBorder.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 60,
                    child: Text(
                      item['value'] as String,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: app.adminAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: app.adminAccent.withOpacity(0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_outlined, size: 13, color: AppColors.grey400),
                const SizedBox(width: 6),
                Text(
                  'Tap a package to view daily revenue calendar',
                  style: AppTextStyles.label.copyWith(color: app.adminTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// ============================================================================
// REVENUE CALENDAR DIALOG
// ============================================================================

class _RevCalDialog extends StatelessWidget {
  final String pkg;
  final DateTime month;
  final DateTime? selected;
  final ValueChanged<DateTime> onMonth, onDay;
  final VoidCallback onClose;
  const _RevCalDialog({
    required this.pkg,
    required this.month,
    required this.selected,
    required this.onMonth,
    required this.onDay,
    required this.onClose,
  });

  static const _ml = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  static const _dl = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dots = [4, 10, 15, 22, 28];
  static const _rev = {4: 2500, 10: 3200, 15: 1800, 22: 4100, 28: 2900};
  static const _bk = {4: 5, 10: 7, 15: 4, 22: 9, 28: 6};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dim = DateTime(month.year, month.month + 1, 0).day;
    final fw = DateTime(month.year, month.month, 1).weekday;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: app.adminAccent.withOpacity(0.20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_ml[month.month - 1]} ${month.year}', style: AppTextStyles.heading3.copyWith(fontSize: 17, color: app.adminTextPrimary)),
                    Text('$pkg Revenue', style: AppTextStyles.bodySmall.copyWith(color: app.adminAccent)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_left, color: AppColors.grey400), onPressed: () => onMonth(DateTime(month.year, month.month - 1))),
              IconButton(icon: const Icon(Icons.chevron_right, color: AppColors.grey400), onPressed: () => onMonth(DateTime(month.year, month.month + 1))),
              GestureDetector(onTap: onClose, child: const Icon(Icons.close_rounded, color: AppColors.grey400, size: 20)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _dl.map((d) => Expanded(
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(color: app.adminTextSecondary),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.1),
            itemCount: (fw - 1) + dim,
            itemBuilder: (_, i) {
              if (i < fw - 1) return const SizedBox();
              final day = i - (fw - 1) + 1;
              final date = DateTime(month.year, month.month, day);
              final hasDot = _dots.contains(day);
              final isSel = selected != null && selected!.year == date.year && selected!.month == date.month && selected!.day == date.day;
              return GestureDetector(
                onTap: () => onDay(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: isSel ? app.adminAccent : Colors.transparent, shape: BoxShape.circle),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSel ? Colors.white : app.adminTextPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      if (hasDot && !isSel) Positioned(bottom: 4, child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.adminAccent, shape: BoxShape.circle))),
                    ],
                  ),
                ),
              );
            },
          ),
          if (selected != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: app.adminCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: app.adminAccent.withOpacity(0.20)),
              ),
              child: Column(
                children: [
                  Text('Mar ${selected!.day}, ${selected!.year}', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _rev[selected!.day] != null ? 'LKR ${_rev[selected!.day]}' : '—',
                    style: AppTextStyles.heading2.copyWith(color: app.adminAccent, fontSize: 22),
                  ),
                  if ((_bk[selected!.day] ?? 0) > 0) Text('(${_bk[selected!.day]} bookings)', style: AppTextStyles.bodySmall.copyWith(color: app.adminAccent2)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// PEAK HOUR HEATMAP
// ============================================================================

class _PeakHeatmap extends StatelessWidget {
  final int? hRow, hCol;
  final Function(int, int, String) onCell;
  const _PeakHeatmap({required this.hRow, required this.hCol, required this.onCell});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _slots = ['8-10 AM', '10-12 PM', '12-2 PM', '2-4 PM', '4-6 PM'];
  static const _data = [
    [3, 2, 4, 5, 3, 2],
    [5, 7, 6, 4, 5, 3],
    [4, 5, 8, 6, 7, 4],
    [6, 8, 7, 5, 9, 3],
    [3, 4, 4, 4, 6, 2],
  ];

  Color _hc(int v) {
    if (v >= 8) return AppColors.adminAccent.withOpacity(0.90);
    if (v >= 6) return AppColors.adminAccent.withOpacity(0.60);
    if (v >= 4) return AppColors.adminAccent.withOpacity(0.35);
    return AppColors.adminAccent.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    int mv = 0, mr = 0, mc = 0;
    for (int r = 0; r < _data.length; r++) {
      for (int c = 0; c < _data[r].length; c++) {
        if (_data[r][c] > mv) {
          mv = _data[r][c];
          mr = r;
          mc = c;
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 58),
              ..._days.map((d) => Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(color: app.adminTextSecondary),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          ..._data.asMap().entries.map((re) {
            final row = re.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(width: 58, child: Text(_slots[row], style: AppTextStyles.label.copyWith(color: app.adminTextSecondary, fontSize: 9))),
                  ..._data[row].asMap().entries.map((ce) {
                    final col = ce.key;
                    final val = ce.value;
                    final hi = hRow == row && hCol == col;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onCell(row, col, '${_days[col]} ${_slots[row]}\n$val bookings'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: hi ? Colors.white.withOpacity(0.20) : _hc(val),
                            borderRadius: BorderRadius.circular(8),
                            border: hi ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                          child: Text(
                            '$val',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Busiest: ${_days[mc]} ${_slots[mr]}', style: AppTextStyles.label.copyWith(color: app.adminAccent2)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEAT TOOLTIP DIALOG
// ============================================================================

class _HeatDialog extends StatelessWidget {
  final String label;
  final VoidCallback onClose;
  const _HeatDialog({required this.label, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final p = label.split('\n');
    return Container(
      margin: const EdgeInsets.all(60),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app.adminAccent.withOpacity(0.30)),
        boxShadow: [BoxShadow(color: app.adminAccent.withOpacity(0.25), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(p[0], style: AppTextStyles.heading3.copyWith(fontSize: 16, color: app.adminTextPrimary))),
              GestureDetector(onTap: onClose, child: const Icon(Icons.close_rounded, color: AppColors.grey400, size: 18)),
            ],
          ),
          const SizedBox(height: 12),
          if (p.length > 1) Text(p[1], style: AppTextStyles.body.copyWith(color: app.adminAccent, fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOMERS LIST
// ============================================================================

class _CustomersList extends StatelessWidget {
  final int? expanded;
  final ValueChanged<int> onExpand;
  const _CustomersList({required this.expanded, required this.onExpand});

  static const _c = [
    {'init': 'KP', 'name': 'Kasun Perera', 'stats': '18 visits · LKR 21,000 total', 'pts': '820 pts', 'last': 'Mar 14', 'fav': 'Hot Desk', 'avg': 'LKR 1,167/visit', 'since': 'Jan 2025'},
    {'init': 'ND', 'name': 'Nimasha De Silva', 'stats': '12 visits · LKR 14,500 total', 'pts': '540 pts', 'last': 'Mar 12', 'fav': 'Private Room', 'avg': 'LKR 1,208/visit', 'since': 'Feb 2025'},
    {'init': 'AF', 'name': 'Amal Fernando', 'stats': '9 visits · LKR 11,200 total', 'pts': '410 pts', 'last': 'Mar 10', 'fav': 'Board Room', 'avg': 'LKR 1,244/visit', 'since': 'Mar 2025'},
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      children: _c.asMap().entries.map((e) {
        final i = e.key;
        final c = e.value;
        final isExp = expanded == i;
        return GestureDetector(
          onTap: () => onExpand(i),
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: app.adminBorder.withOpacity(0.5)))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: app.adminCard.withOpacity(0.6),
                          border: Border.all(color: app.adminBorder),
                        ),
                        child: Center(
                          child: Text(
                            c['init']!,
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['name']!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
                            Text(c['stats']!, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                          ],
                        ),
                      ),
                      Text(c['pts']!, style: AppTextStyles.body.copyWith(color: app.adminAccent2, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (isExp)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: app.adminCard.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: app.adminBorder.withOpacity(0.5)),
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        children: [
                          _CustD('Last Visit', c['last']!),
                          _CustD('Favourite', c['fav']!, color: app.adminAccent2),
                          _CustD('Avg Spend', c['avg']!),
                          _CustD('Member Since', c['since']!),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CustD extends StatelessWidget {
  final String l, v;
  final Color? color;
  const _CustD(this.l, this.v, {this.color});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l, style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
        Text(v, style: AppTextStyles.bodySmall.copyWith(color: color ?? app.adminTextPrimary)),
      ],
    );
  }
}

// ============================================================================
// ANNOUNCEMENT SECTION – single text field + two buttons (visible in light mode)
// ============================================================================

class _AnnounceSection extends StatelessWidget {
  final ValueChanged<String> onMode;
  const _AnnounceSection({required this.onMode});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Weekend 20% off hot desks · Valid Sat–Sun',
              hintStyle: AppTextStyles.body.copyWith(color: app.adminTextSecondary),
              filled: true,
              fillColor: app.adminCard.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: app.adminBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: app.adminBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.adminAccent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onMode('offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app.adminAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Post offer', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onMode('event'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: app.adminAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Post event', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: app.adminAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ANNOUNCEMENT DIALOG – with title, description, picture toggle, date range
// ============================================================================

class _AnnounceDialog extends StatefulWidget {
  final String mode;
  final VoidCallback onClose;
  final ValueChanged<String> onPost;
  const _AnnounceDialog({required this.mode, required this.onClose, required this.onPost});

  @override
  State<_AnnounceDialog> createState() => _AnnounceDialogState();
}

class _AnnounceDialogState extends State<_AnnounceDialog> {
  bool _pics = true;
  DateTime? _from, _to;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool get _isOffer => widget.mode == 'offer';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isFrom) async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.adminAccent)),
        child: child!,
      ),
    );
    if (p != null) {
      setState(() {
        if (isFrom) _from = p;
        else _to = p;
      });
    }
  }

  String _fmt(DateTime? d) => d == null ? 'mm/dd/yyyy' : '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: app.adminCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: app.adminAccent.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isOffer ? 'Post Offer' : 'Post Event',
              style: AppTextStyles.heading3.copyWith(fontSize: 18, color: app.adminTextPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: AppTextStyles.body.copyWith(color: app.adminTextSecondary),
                filled: true,
                fillColor: app.adminCard.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app.adminBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app.adminBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.adminAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: AppTextStyles.body.copyWith(color: app.adminTextSecondary),
                filled: true,
                fillColor: app.adminCard.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app.adminBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: app.adminBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.adminAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PicOption(
                    icon: Icons.image_outlined,
                    label: 'With pictures',
                    selected: _pics,
                    color: app.adminAccent,
                    onTap: () => setState(() => _pics = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PicOption(
                    icon: Icons.text_fields_rounded,
                    label: 'Without pictures',
                    selected: !_pics,
                    color: app.adminAccent2,
                    onTap: () => setState(() => _pics = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Validity period', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: app.adminCard.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: app.adminAccent.withOpacity(0.20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey500),
                          const SizedBox(width: 8),
                          Text(_fmt(_from), style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pick(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: app.adminCard.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: app.adminAccent.withOpacity(0.20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey500),
                          const SizedBox(width: 8),
                          Text(_fmt(_to), style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onPost(_isOffer ? 'Offer posted successfully!' : 'Event posted successfully!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: app.adminAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(_isOffer ? 'Post Offer' : 'Post Event', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picture option toggle button (reusable) ─────────────────────────────────
class _PicOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PicOption({required this.icon, required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : app.adminCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color.withOpacity(0.50) : app.adminBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppColors.grey500, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? Colors.white : app.adminTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ADMIN SETTINGS PAGE – with avatar upload, security dialogs, etc.
// ============================================================================

class _AdminSettingsPage extends StatefulWidget {
  final VoidCallback onBack;
  const _AdminSettingsPage({required this.onBack});

  @override
  State<_AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<_AdminSettingsPage> {
  File? _avatar;
  final _sn = TextEditingController(text: 'Urban Hub');
  final _loc = TextEditingController(text: '123 Galle Road, Colombo 03');
  final _ot = TextEditingController(text: '08:00 AM');
  final _ct = TextEditingController(text: '08:00 PM');
  final _an = TextEditingController(text: 'Ruwan Perera');
  final _ae = TextEditingController(text: 'admin@urbanhub.lk');
  final _ap = TextEditingController(text: '+94 11 234 5678');
  bool _eNotif = true, _pNotif = true;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _avatar = File(picked.path));
      _showPhotoUpdatedToast();
    }
  }

  void _showPhotoUpdatedToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Photo updated!'),
        backgroundColor: AppColors.adminAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pt(TextEditingController c) async {
    final parts = c.text.split(':');
    final ini = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: 0);
    final p = await showTimePicker(context: context, initialTime: ini);
    if (p != null && mounted) setState(() => c.text = p.format(context));
  }

  Widget _passwordField({required TextEditingController controller, required String label, required AppProvider app}) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary),
        filled: true,
        fillColor: app.adminCard.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: app.adminBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: app.adminBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.adminAccent),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final app = context.read<AppProvider>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: app.adminCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: AppTextStyles.heading3.copyWith(color: app.adminTextPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordField(controller: currentCtrl, label: 'Current Password', app: app),
            const SizedBox(height: 12),
            _passwordField(controller: newCtrl, label: 'New Password', app: app),
            const SizedBox(height: 12),
            _passwordField(controller: confirmCtrl, label: 'Confirm New Password', app: app),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Password updated successfully'), backgroundColor: app.adminAccent),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: app.adminAccent),
            child: Text('Update', style: AppTextStyles.body.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _show2FADialog(BuildContext context) {
    final app = context.read<AppProvider>();
    bool enabled = false;
    final TextEditingController otpCtrl = TextEditingController();
    bool otpVerified = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: app.adminCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Two-Factor Authentication', style: AppTextStyles.heading3.copyWith(color: app.adminTextPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enable 2FA', style: AppTextStyles.body.copyWith(color: app.adminTextPrimary)),
                  Switch(
                    value: enabled,
                    onChanged: (val) => setState(() => enabled = val),
                    activeColor: app.adminAccent,
                  ),
                ],
              ),
              if (enabled && !otpVerified) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    hintStyle: AppTextStyles.body.copyWith(color: app.adminTextSecondary),
                    filled: true,
                    fillColor: app.adminCard.withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: app.adminBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: app.adminBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (otpCtrl.text.length == 6) {
                        setState(() => otpVerified = true);
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Invalid OTP'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: app.adminAccent),
                    child: Text('Verify OTP', style: AppTextStyles.body.copyWith(color: Colors.white)),
                  ),
                ),
              ],
              if (enabled && otpVerified)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.adminAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.adminAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.adminAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('2FA enabled and verified', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextPrimary)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(enabled && otpVerified ? '2FA enabled successfully' : '2FA disabled'),
                    backgroundColor: app.adminAccent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: app.adminAccent),
              child: Text('Save', style: AppTextStyles.body.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;
    return Scaffold(
      backgroundColor: app.adminBg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: app.adminAccent.withOpacity(0.06)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: widget.onBack,
                      ),
                      Expanded(
                        child: Text(
                          'Admin Settings',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 17, color: app.adminTextPrimary),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: app.adminAccent.withOpacity(0.20),
                                  border: Border.all(color: app.adminAccent.withOpacity(0.40), width: 2),
                                ),
                                child: ClipOval(
                                  child: _avatar != null
                                      ? Image.file(_avatar!, fit: BoxFit.cover)
                                      : const Icon(Icons.person_outline_rounded, size: 38, color: AppColors.adminAccent),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: app.adminAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: app.adminBg, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Urban Hub Admin', style: AppTextStyles.heading3.copyWith(fontSize: 18, color: app.adminTextPrimary)),
                        Text('admin@urbanhub.lk', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                        const SizedBox(height: 24),

                        _SC(
                          icon: Icons.palette_outlined,
                          title: 'Appearance',
                          child: Row(
                            children: [
                              Expanded(
                                child: _TB(
                                  label: 'Dark',
                                  icon: Icons.dark_mode_rounded,
                                  sel: isDark,
                                  ac: app.adminAccent,
                                  onTap: () => app.setDarkMode(true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TB(
                                  label: 'Light',
                                  icon: Icons.light_mode_rounded,
                                  sel: !isDark,
                                  ac: app.adminAccent,
                                  onTap: () => app.setDarkMode(false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _SC(
                          icon: Icons.business_rounded,
                          title: 'Space Information',
                          child: Column(
                            children: [
                              _SF(c: _sn, l: 'Space Name'),
                              const SizedBox(height: 12),
                              _SF(c: _loc, l: 'Location'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _TF2(c: _ot, l: 'Opening Time', onTap: () => _pt(_ot))),
                                  const SizedBox(width: 12),
                                  Expanded(child: _TF2(c: _ct, l: 'Closing Time', onTap: () => _pt(_ct))),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Space info updated'),
                                        backgroundColor: app.adminAccent,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: app.adminAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Save Changes', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _SC(
                          icon: Icons.person_outline_rounded,
                          title: 'Account',
                          child: Column(
                            children: [
                              _SF(c: _an, l: 'Admin Name'),
                              const SizedBox(height: 12),
                              _SF(c: _ae, l: 'Email', kt: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              _SF(c: _ap, l: 'Phone', kt: TextInputType.phone),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _SC(
                          icon: Icons.lock_outline_rounded,
                          title: 'Security',
                          child: Column(
                            children: [
                              _SecurityRow(
                                label: 'Change Password',
                                onTap: () => _showChangePasswordDialog(context),
                              ),
                              _SecurityRow(
                                label: 'Two-Factor Authentication',
                                onTap: () => _show2FADialog(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _SC(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          child: Column(
                            children: [
                              _TR('Email Notifications', 'Booking alerts, reports', _eNotif, (v) => setState(() => _eNotif = v)),
                              _TR('Push Notifications', 'Live check-ins, payments', _pNotif, (v) => setState(() => _pNotif = v)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        GestureDetector(
                          onTap: () => context.read<AppProvider>().logout(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.red400.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.red400.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, color: AppColors.red400, size: 18),
                                const SizedBox(width: 10),
                                Text('Log Out', style: AppTextStyles.body.copyWith(color: AppColors.red400, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _SC extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SC({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app.adminCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app.adminBorder.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: app.adminAccent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TB extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool sel;
  final Color ac;
  final VoidCallback onTap;
  const _TB({required this.label, required this.icon, required this.sel, required this.ac, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? ac.withOpacity(0.14) : app.adminCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? ac.withOpacity(0.55) : app.adminBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? ac.withOpacity(0.22) : app.adminCard.withOpacity(0.8),
              ),
              child: Icon(icon, size: 22, color: sel ? ac : AppColors.grey500),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: sel ? Colors.white : app.adminTextPrimary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            if (sel)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: ac, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _SF extends StatelessWidget {
  final TextEditingController c;
  final String l;
  final TextInputType kt;
  const _SF({required this.c, required this.l, this.kt = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: kt,
          style: AppTextStyles.body.copyWith(color: app.adminTextPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: app.adminCard.withOpacity(0.6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: app.adminAccent.withOpacity(0.20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: app.adminAccent.withOpacity(0.20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.adminAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class _TF2 extends StatelessWidget {
  final TextEditingController c;
  final String l;
  final VoidCallback onTap;
  const _TF2({required this.c, required this.l, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: app.adminCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: app.adminAccent.withOpacity(0.20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 15, color: AppColors.grey500),
                const SizedBox(width: 8),
                Expanded(child: Text(c.text, style: AppTextStyles.body.copyWith(color: app.adminTextPrimary))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecurityRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: app.adminCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: app.adminBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: app.adminTextPrimary))),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey500, size: 14),
          ],
        ),
      ),
    );
  }
}

class _TR extends StatelessWidget {
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onToggle;
  const _TR(this.label, this.sub, this.value, this.onToggle);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body.copyWith(color: app.adminTextPrimary)),
                Text(sub, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onToggle, activeColor: app.adminAccent),
        ],
      ),
    );
  }
}