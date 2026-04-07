import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/space_model.dart';
import '../models/booking_model.dart';
import '../providers/app_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String  _bookingTab = 'All';
  String? _expandedId;

  static const _tabs = ['All', 'Active', 'Pending', 'Completed', 'Cancelled'];

  List<BookingModel> get _filtered {
    if (_bookingTab == 'All') return kSampleBookings;
    return kSampleBookings.where((b) {
      switch (_bookingTab) {
        case 'Active':    return b.status == BookingStatus.active;
        case 'Pending':   return b.status == BookingStatus.pending;
        case 'Completed': return b.status == BookingStatus.completed;
        case 'Cancelled': return b.status == BookingStatus.cancelled;
        default:          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: _GreetingHeader()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('Overview')),
        ),
        const SliverToBoxAdapter(child: _OverviewCards()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('Discover')),
        ),
        SliverToBoxAdapter(
          child: _DiscoverSection(
            onSpaceSelect: (id) => context.read<AppProvider>().selectSpace(id),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('Announcements & offers')),
        ),
        const SliverToBoxAdapter(child: _AnnouncementsBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('My bookings')),
        ),
        SliverToBoxAdapter(
          child: _BookingTabBar(
            activeTab: _bookingTab,
            onTabChange: (t) => setState(() { _bookingTab = t; _expandedId = null; }),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (_filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No ${_bookingTab.toLowerCase()} bookings found.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                }
                final b = _filtered[i];
                return _BookingTile(
                  booking:    b,
                  isExpanded: _expandedId == b.id,
                  onTap: () => setState(
                      () => _expandedId = _expandedId == b.id ? null : b.id),
                );
              },
              childCount: _filtered.isEmpty ? 1 : _filtered.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('My QR codes')),
        ),
        const SliverToBoxAdapter(child: _QRCodesList()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('Loyalty points')),
        ),
        const SliverToBoxAdapter(child: _LoyaltyPoints()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 24, bottom: 10),
              child: _SectionLabel('Most visited spaces')),
        ),
        SliverToBoxAdapter(
          child: _MostVisitedSpaces(
            onSpaceSelect: (id) => context.read<AppProvider>().selectSpace(id),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary(context),
          fontSize: 13,
        ),
      );
}

// ── Greeting header – now uses dynamic colours ─────────────────────────────
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;
    final bgColor = isDark ? const Color(0xFF114438) : const Color(0xFFD1FAE5);
    final textColor = isDark ? Colors.white : const Color(0xFF064E3B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.appAccent.withOpacity(0.15),
              blurRadius: 20,
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
                    _greeting(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.appAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alex Johnson',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 22,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.read<AppProvider>().setProfileOpen(true),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.appAccent.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.appAccent.withOpacity(0.40),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'AJ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.appAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overview cards – text colours adapted, background uses dynamic surface ──
class _OverviewCards extends StatefulWidget {
  const _OverviewCards();

  @override
  State<_OverviewCards> createState() => _OverviewCardsState();
}

class _OverviewCardsState extends State<_OverviewCards> {
  int? _activeIdx;

  static const _cards = [
    _CardData('Active',     '1',   'session now',  AppColors.appAccent,  false),
    _CardData('Pending',    '3',   'bookings',     AppColors.appAccent,  false),
    _CardData('Points',     '420', 'Silver tier',  AppColors.appAccent2, false),
    _CardData('This month', 'LKR', '12,500',       AppColors.white,      true),
    _CardData('Completed',  '12',  'bookings',     AppColors.appAccent,  false),
    _CardData('Completed',  '5',   'sessions',     AppColors.grey400,    false),
    _CardData('Cancelled',  '1',   'booking',      AppColors.red400,     false),
    _CardData('Hours',      '24',  'total hrs',    AppColors.appAccent2, false),
    _CardData('Savings',    'LKR', '2,500',        AppColors.appAccent,  true),
  ];

  @override
  Widget build(BuildContext context) {
    final hasActive = _activeIdx != null;
    final app = context.watch<AppProvider>();
    return SizedBox(
      height: 108,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _cards.length,
        itemBuilder: (_, i) {
          final c     = _cards[i];
          final isAct = _activeIdx == i;
          return GestureDetector(
            onTap: () => setState(() => _activeIdx = isAct ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 126,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              transform: Matrix4.identity()..scale(
                isAct ? 1.12 : (hasActive ? 0.92 : 1.0)),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: isAct
                    ? AppTheme.surfaceVariant(context).withOpacity(0.8)
                    : AppTheme.surfaceVariant(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAct
                      ? AppColors.appAccent.withOpacity(0.50)
                      : AppTheme.dividerColor(context),
                ),
                boxShadow: isAct
                    ? [BoxShadow(
                        color: AppColors.appAccent.withOpacity(0.25),
                        blurRadius: 20)]
                    : [BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6))],
              ),
              child: AnimatedOpacity(
                opacity: isAct ? 1.0 : (hasActive ? 0.50 : 1.0),
                duration: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
                    const Spacer(),
                    if (c.isCurrency) ...[
                      Text(c.value,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppTheme.textSecondary(context))),
                      Text(c.sub,
                          style: AppTextStyles.heading2
                              .copyWith(color: AppTheme.textPrimary(context), fontSize: 18)),
                    ] else ...[
                      Text(c.value,
                          style: AppTextStyles.heading2.copyWith(
                              color: c.valueColor, fontSize: 22)),
                      Text(c.sub, style: AppTextStyles.label),
                    ],
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

class _CardData {
  final String title, value, sub;
  final Color  valueColor;
  final bool   isCurrency;
  const _CardData(
      this.title, this.value, this.sub, this.valueColor, this.isCurrency);
}

// ── Discover section – dynamic backgrounds ─────────────────────────────────
const double _kTileW   = 196.0;
const double _kTileGap =  10.0;

class _DiscoverSection extends StatefulWidget {
  final ValueChanged<String> onSpaceSelect;
  const _DiscoverSection({required this.onSpaceSelect});

  @override
  State<_DiscoverSection> createState() => _DiscoverSectionState();
}

class _DiscoverSectionState extends State<_DiscoverSection>
    with SingleTickerProviderStateMixin {
  bool _mapMounted = false;

  late final AnimationController _riverCtrl;
  bool _riverPaused = false;
  int? _hoveredIdx;

  static const _spaceIcons = [
    Icons.business_center_rounded,
    Icons.access_time_rounded,
    Icons.coffee_rounded,
    Icons.monitor_rounded,
    Icons.eco_rounded,
    Icons.apartment_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() => _mapMounted = true));

    _riverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _riverCtrl.dispose();
    super.dispose();
  }

  void _pauseRiver()  { if (!_riverPaused) { _riverCtrl.stop(canceled: false); _riverPaused = true; } }
  void _resumeRiver() { if (_riverPaused)  { _riverCtrl.forward(from: _riverCtrl.value); _riverPaused = false; } }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.dividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          SizedBox(
            height: 176,
            child: Stack(children: [
              if (_mapMounted)
                AbsorbPointer(
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(6.925, 79.862),
                      initialZoom: 14,
                      interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: kSampleSpaces
                            .map((s) => Marker(
                                  point: LatLng(s.lat, s.lng),
                                  width: 28,
                                  height: 28,
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.onSpaceSelect(s.id),
                                    child: const _MapDot(),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  color: AppTheme.cardBg(context),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.appAccent, strokeWidth: 2),
                  ),
                ),
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: AppTheme.dividerColor(context)),
                  ),
                  child: Text(
                    '${kSampleSpaces.length} spaces nearby',
                    style: AppTextStyles.label
                        .copyWith(color: AppTheme.textSecondary(context)),
                  ),
                ),
              ),
            ]),
          ),
          MouseRegion(
            onEnter: (_) => _pauseRiver(),
            onExit:  (_) { setState(() => _hoveredIdx = null); _resumeRiver(); },
            child: ClipRect(
              child: SizedBox(
                height: 80,
                child: LayoutBuilder(builder: (ctx, constraints) {
                  const spaces     = kSampleSpaces;
                  final cycleW     = spaces.length * (_kTileW + _kTileGap);
                  final repeatCnt  = ((constraints.maxWidth / cycleW).ceil() + 3).clamp(3, 8).toInt();
                  final tileCount  = spaces.length * repeatCnt;
                  final trackW     = tileCount * _kTileW +
                      (tileCount - 1) * _kTileGap + 24;

                  return AnimatedBuilder(
                    animation: _riverCtrl,
                    builder: (_, __) {
                      final dx = -cycleW + cycleW * _riverCtrl.value;
                      return OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: trackW,
                        maxWidth: trackW,
                        child: Transform.translate(
                          offset: Offset(dx, 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: List.generate(tileCount, (gi) {
                                final si       = gi % spaces.length;
                                final s        = spaces[si];
                                final isHov    = _hoveredIdx == gi;
                                final hasHov   = _hoveredIdx != null;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: gi == tileCount - 1 ? 0 : _kTileGap),
                                  child: MouseRegion(
                                    onEnter: (_) { _pauseRiver(); setState(() => _hoveredIdx = gi); },
                                    onExit:  (_) { if (_hoveredIdx == gi) setState(() => _hoveredIdx = null); },
                                    child: GestureDetector(
                                      onTap: () => widget.onSpaceSelect(s.id),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutCubic,
                                        width: _kTileW,
                                        transform: Matrix4.identity()
                                          ..translate(
                                            0.0,
                                            isHov ? -4.0 : (hasHov ? 3.0 : 0.0),
                                          ),
                                        decoration: BoxDecoration(
                                          color: isHov
                                              ? AppTheme.surfaceVariant(context).withOpacity(0.8)
                                              : AppTheme.surfaceVariant(context),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isHov
                                                ? AppColors.appAccent.withOpacity(0.40)
                                                : AppTheme.dividerColor(context),
                                          ),
                                          boxShadow: isHov
                                              ? [BoxShadow(
                                                  color: AppColors.appAccent.withOpacity(0.25),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 8))]
                                              : [],
                                        ),
                                        child: Row(children: [
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceVariant(context),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              _spaceIcons[si % _spaceIcons.length],
                                              color: AppColors.appAccent,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(s.name,
                                                    style: AppTextStyles.body.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                        color: AppTheme.textPrimary(context)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${s.distanceKm} km · LKR ${s.pricePerHour}/hr',
                                                  style: AppTextStyles.label,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ]),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.appAccent.withOpacity(0.25),
        ),
      ),
      Container(
        width: 12, height: 12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.appAccent,
        ),
        child: const Center(
          child: CircleAvatar(radius: 3, backgroundColor: Colors.white),
        ),
      ),
    ]);
  }
}

// ── Announcements banner – dynamic backgrounds ─────────────────────────────
class _AnnouncementsBanner extends StatefulWidget {
  const _AnnouncementsBanner();

  @override
  State<_AnnouncementsBanner> createState() =>
      _AnnouncementsBannerState();
}

class _AnnouncementsBannerState extends State<_AnnouncementsBanner> {
  late final PageController _pageCtrl;
  int    _page     = 0;
  Timer? _timer;
  int?   _expanded;

  static const _items = [
    _AnnItem(
      title: 'Urban Hub — 20% off Hot Desk this weekend',
      subtitle: 'Valid Sat–Sun · Use at check-in',
      badge: 'Offer',
      bg: Color(0xFF0F4C3A), accent: Color(0xFF00C9A7),
    ),
    _AnnItem(
      title: 'Cafe Works — New event space now open',
      subtitle: 'Board room · 8 seats · From LKR 3,500',
      badge: 'New',
      bg: Color(0xFF3B2D71), accent: Color(0xFFA78BFA),
    ),
    _AnnItem(
      title: 'The Hive — Free coffee with any booking',
      subtitle: 'Valid all week · Show QR at counter',
      badge: 'Perk',
      bg: Color(0xFF1E3A8A), accent: Color(0xFF60A5FA),
    ),
    _AnnItem(
      title: 'Studio 54 — Early bird 30% off before 9 AM',
      subtitle: 'Mon–Fri · Hot desk only',
      badge: 'Deal',
      bg: Color(0xFF78350F), accent: Color(0xFFFBBF24),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.86);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_page + 1) % _items.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      setState(() => _page = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.appAccent.withOpacity(0.20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (p) => setState(() => _page = p),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return GestureDetector(
                    onTap: () => setState(
                        () => _expanded = _expanded == i ? null : i),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: item.bg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: item.accent.withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.title,
                                  style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(item.subtitle,
                                  style: AppTextStyles.label.copyWith(
                                      color: item.accent.withOpacity(0.80))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.accent.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: item.accent.withOpacity(0.30)),
                          ),
                          child: Text(item.badge,
                              style: AppTextStyles.label.copyWith(
                                  color: item.accent,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_items.length, (i) {
              final active = _page == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width:  active ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.appAccent
                      : AppTheme.dividerColor(context),
                  borderRadius: BorderRadius.circular(50),
                ),
              );
            }),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _expanded != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _AnnExpandedCard(item: _items[_expanded!]),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

class _AnnItem {
  final String title, subtitle, badge;
  final Color  bg, accent;
  const _AnnItem({required this.title, required this.subtitle,
      required this.badge, required this.bg, required this.accent});
}

class _AnnExpandedCard extends StatelessWidget {
  final _AnnItem item;
  const _AnnExpandedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.accent.withOpacity(0.20)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: item.accent.withOpacity(0.20),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: item.accent.withOpacity(0.30)),
          ),
          child: Text(item.badge,
              style: AppTextStyles.label.copyWith(color: item.accent)),
        ),
        const SizedBox(height: 8),
        Text(item.title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(item.subtitle,
            style: AppTextStyles.bodySmall
                .copyWith(color: item.accent.withOpacity(0.80))),
      ]),
    );
  }
}

// ── Booking tab bar – dynamic colours ─────────────────────────────────────
class _BookingTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChange;
  static const _tabs = ['All', 'Active', 'Pending', 'Completed', 'Cancelled'];
  const _BookingTabBar({required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final t     = _tabs[i];
          final isAct = activeTab == t;
          return GestureDetector(
            onTap: () => onTabChange(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isAct
                    ? const LinearGradient(
                        colors: [AppColors.appAccent, Color(0xFF10C7BE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isAct ? null : AppTheme.surfaceVariant(context),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isAct
                      ? AppColors.appAccent.withOpacity(0.50)
                      : AppTheme.dividerColor(context),
                ),
                boxShadow: isAct
                    ? [BoxShadow(
                        color: AppColors.appAccent.withOpacity(0.40),
                        blurRadius: 15)]
                    : [],
              ),
              child: Text(t,
                  style: AppTextStyles.body.copyWith(
                    color: isAct ? Colors.white : AppTheme.textSecondary(context),
                    fontWeight: isAct ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  )),
            ),
          );
        },
      ),
    );
  }
}

// ── Booking tile – dynamic text colours, uses theme‑aware card background ──
class _BookingTile extends StatelessWidget {
  final BookingModel booking;
  final bool         isExpanded;
  final VoidCallback onTap;

  const _BookingTile({
    required this.booking,
    required this.isExpanded,
    required this.onTap,
  });

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.active:    return AppColors.appAccent;
      case BookingStatus.pending:   return AppColors.orange400;
      case BookingStatus.completed: return AppColors.grey400;
      case BookingStatus.cancelled: return AppColors.red400;
    }
  }

  String _statusLabel(BookingModel b) {
    switch (b.status) {
      case BookingStatus.active:    return 'Active';
      case BookingStatus.pending:   return 'Pending';
      case BookingStatus.completed: return 'Done';
      case BookingStatus.cancelled:
        return b.cancelledBy == CancelledBy.space ? 'Rejected' : 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(booking.status);
    final app = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.dividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
                    const SizedBox(height: 3),
                    Text(booking.subtitle, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.withOpacity(0.30)),
                ),
                child: Text(_statusLabel(booking),
                    style: AppTextStyles.label.copyWith(color: c)),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey400, size: 18),
              ),
            ]),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _BookingDetails(booking: booking),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ]),
      ),
    );
  }
}

class _BookingDetails extends StatelessWidget {
  final BookingModel booking;
  const _BookingDetails({required this.booking});

  String get _paymentLabel {
    switch (booking.status) {
      case BookingStatus.pending:   return 'Pending';
      case BookingStatus.cancelled: return 'Refunded';
      default:                      return 'Paid';
    }
  }

  Color get _paymentColor {
    switch (booking.status) {
      case BookingStatus.pending:   return AppColors.orange400;
      case BookingStatus.cancelled: return AppColors.red400;
      default:                      return AppColors.appAccent;
    }
  }

  String get _qrLabel =>
      booking.status == BookingStatus.active ? 'Active' : 'Expired';

  Color get _qrColor =>
      booking.status == BookingStatus.active
          ? AppColors.appAccent
          : AppColors.grey400;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor(context)),
        ),
        child: Column(children: [
          if (booking.cancelledBy == CancelledBy.space &&
              booking.cancelReason != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.red400.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.red400.withOpacity(0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.red400, size: 13),
                    const SizedBox(width: 5),
                    Text('Cancelled by Space',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.red400,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 5),
                  Text(booking.cancelReason!,
                      style: AppTextStyles.bodySmall),
                  if (booking.cancelledByAdmin != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text('— ${booking.cancelledByAdmin}',
                          style: AppTextStyles.label),
                    ),
                ],
              ),
            ),
          _DetailRow(Icons.location_on_outlined, booking.address),
          const SizedBox(height: 7),
          _DetailRow(Icons.access_time_rounded,
              '${booking.checkIn} — ${booking.checkOut} (${booking.duration})'),
          const SizedBox(height: 7),
          _DetailRow(Icons.credit_card_outlined, booking.price,
              valueColor: app.adminTextPrimary),
          const SizedBox(height: 7),
          _DetailRow(Icons.calendar_today_outlined,
              'Booking #${booking.id}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1,
                color: AppTheme.dividerColor(context)),
          ),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAYMENT',
                      style: AppTextStyles.label
                          .copyWith(letterSpacing: 1.0, color: app.adminTextSecondary)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _paymentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        booking.status == BookingStatus.cancelled
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                        size: 12,
                        color: _paymentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(_paymentLabel,
                          style: AppTextStyles.label.copyWith(
                              color: _paymentColor,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QR CODE',
                      style: AppTextStyles.label
                          .copyWith(letterSpacing: 1.0, color: app.adminTextSecondary)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _qrColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.qr_code_2_rounded,
                          size: 12, color: _qrColor),
                      const SizedBox(width: 4),
                      Text(_qrLabel,
                          style: AppTextStyles.label.copyWith(
                              color: _qrColor,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final Color?   valueColor;
  const _DetailRow(this.icon, this.text, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 13, color: AppColors.appAccent),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: AppTextStyles.bodySmall.copyWith(
                color: valueColor ?? app.adminTextSecondary)),
      ),
    ]);
  }
}

// ── QR codes list – dynamic backgrounds ────────────────────────────────────
class _QRCodesList extends StatelessWidget {
  const _QRCodesList();

  static const _codes = [
    _QRItem('1', 'Urban Hub — Hot Desk',         'Expires today 5:00 PM',    true),
    _QRItem('2', 'Cafe Works — Hot Desk',         'Expired Mar 12',           false),
    _QRItem('3', 'The Hive — Private Room',       'Expires tomorrow 6:00 PM', true),
    _QRItem('4', 'Studio 54 — Board Room',        'Expired Mar 8',            false),
  ];

  int get _activeCount  => _codes.where((q) => q.active).length;
  int get _expiredCount => _codes.where((q) => !q.active).length;
  double get _activePct => _codes.isEmpty ? 0 : _activeCount / _codes.length;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.dividerColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.appAccent),
                  const SizedBox(width: 5),
                  Text('$_activeCount',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
                  const SizedBox(width: 4),
                  Text('active', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                  Container(
                    width: 1, height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: AppTheme.dividerColor(context),
                  ),
                  const Icon(Icons.cancel_outlined,
                      size: 14, color: AppColors.grey400),
                  const SizedBox(width: 5),
                  Text('$_expiredCount',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
                  const SizedBox(width: 4),
                  Text('expired', style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                ]),
                Text('${_codes.length} total',
                    style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                height: 8,
                child: Row(children: [
                  Expanded(
                    flex: (_activePct * 100).round(),
                    child: Container(color: AppColors.appAccent),
                  ),
                  Expanded(
                    flex: 100 - (_activePct * 100).round(),
                    child: Container(color: AppTheme.dividerColor(context)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(_activePct * 100).round()}% active',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.appAccent,
                        fontWeight: FontWeight.w500)),
                Text('${(100 - _activePct * 100).round()}% expired',
                    style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.dividerColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _codes.map((qr) {
              final isLast = _codes.last == qr;
              return Column(children: [
                InkWell(
                  onTap: () {
                    context.read<AppProvider>().setSelectedQRCode({
                      'spaceName': qr.title.split(' — ').first,
                      'unitType':  qr.title.split(' — ').last,
                      'checkIn':   '09:00 AM',
                      'checkOut':  '05:00 PM',
                      'status':    qr.active ? 'Active' : 'Expired',
                      'expiresIn': qr.subtitle,
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: qr.active
                              ? AppColors.appAccent.withOpacity(0.10)
                              : AppColors.red400.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: qr.active
                                ? AppColors.appAccent.withOpacity(0.20)
                                : AppColors.red400.withOpacity(0.20),
                          ),
                        ),
                        child: Icon(Icons.qr_code_2_rounded,
                            color: qr.active
                                ? AppColors.appAccent
                                : AppColors.red400,
                            size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(qr.title,
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: app.adminTextPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(qr.subtitle,
                                style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: qr.active
                              ? AppColors.appAccent.withOpacity(0.20)
                              : AppColors.red400.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: qr.active
                                ? AppColors.appAccent.withOpacity(0.30)
                                : AppColors.red400.withOpacity(0.30),
                          ),
                        ),
                        child: Text(
                          qr.active ? 'Active' : 'Expired',
                          style: AppTextStyles.label.copyWith(
                            color: qr.active
                                ? AppColors.appAccent
                                : AppColors.red400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: AppTheme.dividerColor(context)),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _QRItem {
  final String id, title, subtitle;
  final bool   active;
  const _QRItem(this.id, this.title, this.subtitle, this.active);
}

// ── Loyalty points – dynamic backgrounds ───────────────────────────────────
class _LoyaltyPoints extends StatelessWidget {
  const _LoyaltyPoints();

  @override
  Widget build(BuildContext context) {
    const current = 420;
    const target  = 680;
    final app = context.watch<AppProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Silver tier',
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
              Text('$current / $target pts to Gold',
                  style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: current / target,
              minHeight: 8,
              backgroundColor: AppTheme.dividerColor(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.appAccent),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${target - current} more points to reach Gold tier',
              style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Most visited spaces – dynamic backgrounds ──────────────────────────────
class _MostVisitedSpaces extends StatelessWidget {
  final ValueChanged<String> onSpaceSelect;
  const _MostVisitedSpaces({required this.onSpaceSelect});

  static const _spaces = [
    _VisitedSpace('1', 1, 'Urban Hub',  '12 visits · LKR 8,400 spent', 4.8),
    _VisitedSpace('2', 2, 'Cafe Works', '7 visits · LKR 4,100 spent',  4.5),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: _spaces.map((s) {
            final isLast = _spaces.last.id == s.id;
            return Column(children: [
              InkWell(
                onTap: () => onSpaceSelect(s.id),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.rank == 1
                            ? AppColors.appAccent.withOpacity(0.20)
                            : AppTheme.surfaceVariant(context),
                        border: Border.all(
                          color: s.rank == 1
                              ? AppColors.appAccent.withOpacity(0.30)
                              : AppTheme.dividerColor(context),
                        ),
                      ),
                      child: Center(
                        child: Text('${s.rank}',
                            style: AppTextStyles.body.copyWith(
                              color: s.rank == 1
                                  ? AppColors.appAccent
                                  : app.adminTextSecondary,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w500, color: app.adminTextPrimary)),
                          const SizedBox(height: 2),
                          Text(s.stats, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
                        ],
                      ),
                    ),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: AppColors.appAccent),
                      const SizedBox(width: 3),
                      Text(s.rating.toStringAsFixed(1),
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.appAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                    ]),
                  ]),
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: AppTheme.dividerColor(context)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _VisitedSpace {
  final String id, name, stats;
  final int    rank;
  final double rating;
  const _VisitedSpace(this.id, this.rank, this.name, this.stats, this.rating);
}