import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/space_model.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/header_widget.dart';

class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key});

  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  String _activeFilter = 'All';
  String _activeSort   = 'rating';
  bool   _sortOpen     = false;

  static const _filters = [
    'All', 'Hot Desk', 'Private Office', 'Meeting Room', 'Event Space',
  ];

  static const _sorts = {
    'rating'    : 'Rating',
    'distance'  : 'Distance',
    'price-low' : 'Price Low',
    'price-high': 'Price High',
    'newest'    : 'Newest',
  };

  List<SpaceModel> get _sorted {
    final filtered = _activeFilter == 'All'
        ? List<SpaceModel>.from(kSampleSpaces)
        : kSampleSpaces
            .where((s) => s.types.contains(_activeFilter))
            .toList();
    switch (_activeSort) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price-low':
        filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'price-high':
        filtered.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case 'distance':
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 'newest':
        filtered.sort((a, b) {
          final bId = int.tryParse(b.id) ?? 0;
          final aId = int.tryParse(a.id) ?? 0;
          return bId.compareTo(aId);
        });
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final sortedSpaces = _sorted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        CustomScrollView(slivers: [
          const SliverToBoxAdapter(child: HeaderWidget()),

          // ── Title ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Spaces',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppTheme.textPrimary(context),
                      )),
                  const SizedBox(height: 4),
                  Text('Find the perfect spot to work today.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textSecondary(context),
                      )),
                ],
              ),
            ),
          ),

          // ── Filters + Sort ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Sort chip
                  GestureDetector(
                    onTap: () => setState(() => _sortOpen = true),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.appAccent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: AppColors.appAccent.withOpacity(0.70)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.sort_rounded,
                            color: AppColors.appAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(_sorts[_activeSort] ?? 'Sort',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.appAccent,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.appAccent, size: 14),
                      ]),
                    ),
                  ),
                  // divider
                  Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      color: AppTheme.dividerColor(context)),
                  // Filter chips
                  ..._filters.map((f) {
                    final active = _activeFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.appAccent
                              : AppTheme.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: active
                                ? AppColors.appAccent
                                : AppTheme.dividerColor(context),
                          ),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.appAccent.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(f,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondary(context),
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.all(6),
                  child: _SpaceCard(space: sortedSpaces[i]),
                ),
                childCount: sortedSpaces.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ]),

        // ── Sort bottom sheet ─────────────────────────────────────
        if (_sortOpen) ...[
          GestureDetector(
            onTap: () => setState(() => _sortOpen = false),
            child: Container(color: Colors.black.withOpacity(0.50)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _SortSheet(
              current: _activeSort,
              sorts: _sorts,
              onSelect: (v) => setState(() {
                _activeSort = v;
                _sortOpen   = false;
              }),
              onClose: () => setState(() => _sortOpen = false),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Space card — mirrors SavedPage's _PoppableSpaceCard style
// ─────────────────────────────────────────────────────────────────────────────

class _SpaceCard extends StatefulWidget {
  final SpaceModel space;
  const _SpaceCard({required this.space});

  @override
  State<_SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<_SpaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _borderOpacity;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _borderOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.45)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    context.read<AppProvider>().selectSpace(widget.space.id);
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final isDark = context.watch<AppProvider>().isDarkMode;

    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.appAccent
                    .withOpacity(_borderOpacity.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(isDark ? 0.25 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.appAccent
                      .withOpacity(_glowOpacity.value),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(
                  imageUrl: space.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppTheme.cardBg(context)),
                  errorWidget: (_, __, ___) => Container(
                      color: AppTheme.cardBg(context),
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.grey500)),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          (isDark
                                  ? AppColors.appCardDark
                                  : AppColors.appCardLight)
                              .withOpacity(0.80),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tag badge
                if (space.tag != null)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.appAccent.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(space.tag!,
                          style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ]),
            ),

            // ── Info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.appAccent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.appAccent
                                  .withOpacity(0.20)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 11, color: AppColors.appAccent),
                          const SizedBox(width: 3),
                          Text(space.rating.toStringAsFixed(1),
                              style: AppTextStyles.label.copyWith(
                                  color: AppColors.appAccent,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      // Seats
                      Row(children: [
                        const Icon(Icons.people_outline,
                            size: 13, color: AppColors.appAccent2),
                        const SizedBox(width: 3),
                        Text('${space.seats}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textSecondary(context),
                            )),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort bottom sheet — theme-aware
// ─────────────────────────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final String current;
  final Map<String, String> sorts;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  const _SortSheet({
    required this.current,
    required this.sorts,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
            top: BorderSide(color: AppTheme.dividerColor(context))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sort by',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 18,
                      color: AppTheme.textPrimary(context),
                    )),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary(context)),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          ...sorts.entries.map((e) {
            final isActive = current == e.key;
            return InkWell(
              onTap: () => onSelect(e.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? AppColors.appAccent
                                : AppTheme.textPrimary(context))),
                    if (isActive)
                      const Icon(Icons.check_rounded,
                          color: AppColors.appAccent, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}