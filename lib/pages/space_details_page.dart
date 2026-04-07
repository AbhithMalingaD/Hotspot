import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/space_model.dart';
import '../models/review_model.dart';
import '../providers/app_provider.dart';

class SpaceDetailsPage extends StatefulWidget {
  final String spaceId;
  const SpaceDetailsPage({super.key, required this.spaceId});

  @override
  State<SpaceDetailsPage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpaceDetailsPage> {
  String _selectedPkg = 'p1';
  String? _toast;

  static const _packages = [
    {'id': 'p1', 'name': 'Hot Desk',            'price': 500,  'cap': 20, 'avail': 5},
    {'id': 'p2', 'name': 'Private Meeting Room', 'price': 1500, 'cap': 6,  'avail': 1},
    {'id': 'p3', 'name': 'Board Room',           'price': 3500, 'cap': 12, 'avail': 0},
    {'id': 'p4', 'name': 'Event Space',          'price': 8000, 'cap': 50, 'avail': 50},
  ];

  void _showToast(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 2),
        () { if (mounted) setState(() => _toast = null); });
  }

  SpaceModel get _space => kSampleSpaces.firstWhere(
        (s) => s.id == widget.spaceId,
        orElse: () => kSampleSpaces.first);

  @override
  Widget build(BuildContext context) {
    final space = _space;
    final app = context.watch<AppProvider>();
    final isSaved = app.isSpaceSaved(space.id);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Image.network(
                  space.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppTheme.cardBg(context)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bg(context)],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () =>
                              context.read<AppProvider>().clearSpace(),
                        ),
                        _CircleIconButton(
                          icon: isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor:
                              isSaved ? AppColors.appAccent : AppTheme.textPrimary(context),
                          onTap: () {
                            app.toggleSavedSpace(space.id);
                            _showToast(isSaved
                                ? 'Removed from saved'
                                : 'Saved to your spaces');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (space.tag != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 56,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.appAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.appAccent.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(
                        space.tag!.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(space.name,
                          style: AppTextStyles.heading1
                              .copyWith(fontSize: 28, color: AppTheme.textPrimary(context))),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.appAccent),
                        const SizedBox(width: 4),
                        Text('${space.rating} (124 reviews)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppTheme.textSecondary(context))),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.appAccent2),
                        const SizedBox(width: 4),
                        Text('08:00 - 20:00',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppTheme.textSecondary(context))),
                        const Spacer(),
                        const Icon(Icons.people_outline_rounded,
                            size: 14, color: AppColors.appAccent2),
                        const SizedBox(width: 4),
                        Text('${space.seats} seats',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppTheme.textSecondary(context))),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.appAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(space.address,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppTheme.textSecondary(context))),
                        ),
                        Text('(${space.distanceKm} km)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.appAccent)),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Amenities', style: AppTextStyles.heading3.copyWith(color: AppTheme.textPrimary(context))),
                const SizedBox(height: 12),
                const _AmenitiesRow(),
                const SizedBox(height: 24),
                Text('Available Packages', style: AppTextStyles.heading3.copyWith(color: AppTheme.textPrimary(context))),
                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 14),
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.appAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ..._packages.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PackageTile(
                        id: p['id'] as String,
                        name: p['name'] as String,
                        price: p['price'] as int,
                        capacity: p['cap'] as int,
                        available: p['avail'] as int,
                        isSelected: _selectedPkg == p['id'],
                        onTap: () {
                          if ((p['avail'] as int) > 0) {
                            setState(() => _selectedPkg = p['id'] as String);
                          }
                        },
                      ),
                    )),
                _ReviewsSection(spaceId: widget.spaceId),
              ]),
            ),
          ),
        ]),
        if (_toast != null)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: AppColors.appAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.appAccent),
                  const SizedBox(width: 6),
                  Text(_toast!,
                      style: AppTextStyles.body.copyWith(fontSize: 13, color: AppTheme.textPrimary(context))),
                ]),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.bg(context),
                  AppTheme.bg(context).withOpacity(0),
                ],
              ),
            ),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<AppProvider>().setDirectionsOpen(true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.appAccent),
                    foregroundColor: AppColors.appAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text('Directions',
                      style: AppTextStyles.body.copyWith(color: AppColors.appAccent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => context
                      .read<AppProvider>()
                      .openBookingForm(space.name, _selectedPkg),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: Text('Book This Space',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Circle icon button ────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
                color: AppColors.appAccent.withOpacity(0.12),
                blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}

// ── Amenities row – dynamic colours ─────────────────────────────────────────
class _AmenitiesRow extends StatelessWidget {
  const _AmenitiesRow();

  static const _amenities = [
    {'icon': Icons.wifi_rounded,          'label': 'WiFi',     'on': true},
    {'icon': Icons.coffee_rounded,        'label': 'Coffee',   'on': true},
    {'icon': Icons.ac_unit_rounded,       'label': 'AC',       'on': true},
    {'icon': Icons.local_parking_rounded, 'label': 'Parking',  'on': false},
    {'icon': Icons.print_rounded,         'label': 'Printing', 'on': true},
    {'icon': Icons.vpn_key_rounded,       'label': '24hr',     'on': true},
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _amenities.map((a) {
        final on = a['on'] as bool;
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: on
                ? AppColors.appAccent.withOpacity(0.12)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: on
                  ? AppColors.appAccent.withOpacity(0.35)
                  : AppTheme.dividerColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(a['icon'] as IconData,
                  size: 13,
                  color: on ? AppColors.appAccent : AppColors.grey500),
              const SizedBox(width: 6),
              Text(a['label'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: on ? Colors.white : app.adminTextSecondary,
                      fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Package tile – dynamic colours ────────────────────────────────────────────
class _PackageTile extends StatelessWidget {
  final String id, name;
  final int price, capacity, available;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageTile({
    required this.id,
    required this.name,
    required this.price,
    required this.capacity,
    required this.available,
    required this.isSelected,
    required this.onTap,
  });

  static IconData _icon(String id) {
    switch (id) {
      case 'p1': return Icons.work_outline_rounded;
      case 'p2': return Icons.people_outline_rounded;
      case 'p3': return Icons.desktop_windows_outlined;
      case 'p4': return Icons.mic_none_rounded;
      default:   return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final canBook = available > 0;
    final selected = isSelected && canBook;

    return GestureDetector(
      onTap: canBook ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.appAccent.withOpacity(0.10)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.appAccent
                : AppTheme.dividerColor(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.appAccent.withOpacity(0.20)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon(id),
                color: selected
                    ? AppColors.appAccent
                    : AppColors.appAccent2,
                size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
                const SizedBox(height: 3),
                Text('LKR $price/hr',
                    style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                canBook ? '$available seats left' : 'FULLY BOOKED',
                style: AppTextStyles.label.copyWith(
                  color: canBook ? AppColors.appAccent : AppColors.red400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.appAccent
                      : (canBook
                          ? AppTheme.dividerColor(context)
                          : AppColors.red400.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? AppColors.appAccent
                        : (canBook
                            ? Colors.white.withOpacity(0.15)
                            : AppColors.red400.withOpacity(0.4)),
                  ),
                ),
                child: Text(
                  selected ? 'Selected' : (canBook ? 'Select' : 'Select'),
                  style: AppTextStyles.label.copyWith(
                    color: selected
                        ? Colors.white
                        : (canBook ? app.adminTextSecondary : AppColors.red400),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ── Reviews section – dynamic colours ────────────────────────────────────────
class _ReviewsSection extends StatelessWidget {
  final String spaceId;
  const _ReviewsSection({required this.spaceId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final reviews = app.getSpaceReviews(spaceId);
    final hasVisited = app.hasUserVisitedSpace(spaceId);
    final alreadyReviewed = app.hasUserReviewedSpace(spaceId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Reviews', style: AppTextStyles.heading3.copyWith(color: AppTheme.textPrimary(context))),
        const SizedBox(height: 12),
        const _ReviewTile(
          name: 'Sarah J.',
          date: '2 days ago',
          rating: 5,
          comment: 'Great space with fast WiFi. The coffee is amazing!',
        ),
        const _ReviewTile(
          name: 'Mike R.',
          date: '1 week ago',
          rating: 4,
          comment:
              'Good location but parking can be tricky during peak hours.',
        ),
        ...reviews.map((r) => _ReviewTile(
              name: r.userName,
              date: _formatDate(r.date),
              rating: r.rating,
              comment: r.comment,
            )),
        const SizedBox(height: 12),
        if (!alreadyReviewed)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  hasVisited ? () => _showReviewDialog(context) : null,
              icon: const Icon(Icons.star_border_rounded,
                  size: 16, color: AppColors.appAccent),
              label: Text('Write a Review',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.appAccent)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(
                    color: AppColors.appAccent, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        else
          Text('You already reviewed this space',
              style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
        const SizedBox(height: 16),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReviewDialog(BuildContext context) {
    int selectedRating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Text('Write a Review',
              style: AppTextStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedRating = i + 1),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 32,
                        color: i < selectedRating
                            ? AppColors.appAccent
                            : AppColors.grey500,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: AppTextStyles.bodySmall,
                  filled: true,
                  fillColor: AppTheme.surfaceVariant(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: AppTheme.dividerColor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: AppTheme.dividerColor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppColors.appAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.bodySmall),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedRating == 0) return;
                context.read<AppProvider>().addReview(
                      spaceId,
                      Review(
                        userName: 'You',
                        userAvatar: 'Y',
                        rating: selectedRating,
                        comment: commentController.text,
                        date: DateTime.now(),
                      ),
                    );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review tile – dynamic colours ───────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final String name, date, comment;
  final int rating;

  const _ReviewTile({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.appAccent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.appAccent),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600, color: app.adminTextPrimary)),
                  Text(date, style: AppTextStyles.label.copyWith(color: app.adminTextSecondary)),
                ],
              ),
            ),
            Row(children: [
              const Icon(Icons.star_rounded,
                  size: 13, color: AppColors.appAccent),
              const SizedBox(width: 3),
              Text('$rating',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppTheme.textSecondary(context))),
            ]),
          ]),
          const SizedBox(height: 8),
          Text(comment, style: AppTextStyles.bodySmall.copyWith(color: app.adminTextSecondary)),
        ],
      ),
    );
  }
}