import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';
import '../models/space_model.dart';
import '../providers/app_provider.dart';
import 'package:provider/provider.dart';

class SpaceCard extends StatefulWidget {
  final SpaceModel space;
  final int index;

  const SpaceCard({super.key, required this.space, required this.index});

  @override
  State<SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final space = widget.space;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.read<AppProvider>().selectSpace(space.id);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: AppDecorations.glassCard.copyWith(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ───────────────────────────────────────────────
              SizedBox(
                height: 130,
                child: Stack(fit: StackFit.expand, children: [
                  CachedNetworkImage(
                    imageUrl: space.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: AppColors.appCard),
                    errorWidget: (_, __, ___) => Container(
                        color: AppColors.appCard,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.grey500)),
                  ),
                  // gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.appCard.withOpacity(0.80),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (space.tag != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.appAccent
                              .withOpacity(0.90),
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

              // ── Info ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(space.name,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.05),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.05)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.star_rounded,
                                size: 12,
                                color: AppColors.appAccent),
                            const SizedBox(width: 3),
                            Text(
                                space.rating.toStringAsFixed(1),
                                style: AppTextStyles.label
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.w600)),
                          ]),
                        ),
                        // Seats
                        Row(children: [
                          const Icon(Icons.people_outline,
                              size: 14,
                              color: AppColors.appAccent2),
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
      ),
    );
  }
}