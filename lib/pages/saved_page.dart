import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/space_model.dart';
import '../providers/app_provider.dart';
import '../widgets/header_widget.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const _savedIds   = ['1', '3', '5'];
  static const _visitedIds = ['1', '2', '4'];

  // Track visit counts per space
  static const _visitCounts = {'1': 12, '2': 7, '3': 5, '4': 3, '5': 8};

  List<SpaceModel> _getSpaces(List<String> ids) => ids
      .map((id) => kSampleSpaces.firstWhere(
            (s) => s.id == id,
            orElse: () => kSampleSpaces.first,
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final saved   = _getSpaces(_savedIds);
    final visited = _getSpaces(_visitedIds);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: HeaderWidget()),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved Spaces', style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Text(
                  'Your bookmarked co-working spots for quick access.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),

        // ── Saved grid ──────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.all(6),
                child: _PoppableSpaceCard(
                  space: saved[i],
                  visitCount: _visitCounts[saved[i].id] ?? 0,
                ),
              ),
              childCount: saved.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Previously Visited',
                    style:
                        AppTextStyles.heading3.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text("Spaces you've worked from recently.",
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),

        // ── Visited grid ────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.all(6),
                child: _PoppableSpaceCard(
                  space: visited[i],
                  visitCount: _visitCounts[visited[i].id] ?? 0,
                ),
              ),
              childCount: visited.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIX 8 — Poppable card that SCALES UP + glows on press
// ─────────────────────────────────────────────────────────────────────────────

class _PoppableSpaceCard extends StatefulWidget {
  final SpaceModel space;
  final int        visitCount;

  const _PoppableSpaceCard({
    required this.space,
    required this.visitCount,
  });

  @override
  State<_PoppableSpaceCard> createState() => _PoppableSpaceCardState();
}

class _PoppableSpaceCardState extends State<_PoppableSpaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _borderOpacity;
  late final Animation<double>   _glowOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _borderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.50).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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

    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                // Base card decoration
                color: AppTheme.surfaceVariant(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  // Border glows teal on press
                  color: AppColors.appAccent
                      .withOpacity(_borderOpacity.value),
                  width: 2,
                ),
                boxShadow: [
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  // Teal glow on press
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
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ────────────────────────────────────────
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
                          AppTheme.cardBg(context).withOpacity(0.85),
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
                        color: AppColors.appAccent.withOpacity(0.90),
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

            // ── Info section ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  // Visit count
                  if (widget.visitCount > 0) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      Text(
                        '${widget.visitCount}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.appAccent,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 3),
                      Text('visits',
                          style: AppTextStyles.label
                              .copyWith(fontSize: 10)),
                    ]),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.surfaceVariant(context)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 11, color: AppColors.appAccent),
                          const SizedBox(width: 3),
                          Text(space.rating.toStringAsFixed(1),
                              style: AppTextStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      // Seats
                      Row(children: [
                        const Icon(Icons.people_outline,
                            size: 13, color: AppColors.appAccent2),
                        const SizedBox(width: 3),
                        Text('${space.seats}',
                            style: AppTextStyles.bodySmall),
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