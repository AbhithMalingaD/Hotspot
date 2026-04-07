import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/space_model.dart';
import '../providers/app_provider.dart';
import '../widgets/header_widget.dart';

const double _kHomeMapHeight = 300;
const double _kFloatingRiverHeight = 248;
const double _kFloatingRiverGap = 24;
const double _kFloatingRiverBottomGap = 112;
const double _kRiverCardWidth = 160;
const double _kRiverCardGap = 12;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _searchFocused = false;
  String _query = '';
  bool _isLoadingLocation = false;
  LatLng? _userLocation;

  List<SpaceModel> get _filtered => _query.trim().isEmpty
      ? kSampleSpaces
      : kSampleSpaces
          .where((s) =>
              s.name.toLowerCase().contains(_query.toLowerCase()) ||
              s.address.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChange);
  }

  void _handleSearchFocusChange() {
    if (!mounted) return;
    setState(() => _searchFocused = _searchFocusNode.hasFocus);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  void _handleSearchSelect(String id) {
    _searchFocusNode.unfocus();
    _clearSearch();
    context.read<AppProvider>().selectSpace(id);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permission denied.');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      _showLocationError('Could not get your location.');
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_handleSearchFocusChange)
      ..dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: HeaderWidget()),
              SliverToBoxAdapter(
                child: _SearchBar(
                  controller: _searchCtrl,
                  focusNode: _searchFocusNode,
                  isFocused: _searchFocused,
                  spaces: _filtered,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: _clearSearch,
                  onSelect: _handleSearchSelect,
                ),
              ),
          SliverToBoxAdapter(
            child: _MapShowcaseSection(
              focused: _searchFocused,
              userLocation: _userLocation,
            ),
          ),
            ],
          ),
          if (!_isLoadingLocation)
            Positioned(
              bottom: 120,
              right: 24,
              child: GestureDetector(
                onTap: _getCurrentLocation,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.appAccent.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.my_location_rounded, color: AppColors.appAccent, size: 22),
                ),
              ),
            )
          else
            Positioned(
              bottom: 120,
              right: 24,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.appAccent.withOpacity(0.5)),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.appAccent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  static const double _searchFieldHeight = 56;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final List<SpaceModel> spaces;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSelect;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.spaces,
    required this.onChanged,
    required this.onClear,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Text('Find Your Co-Working Space',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _searchFieldHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.appAccent
                      .withOpacity(isFocused ? 0.28 : 0.16),
                  blurRadius: isFocused ? 26 : 18,
                  spreadRadius: isFocused ? 1 : 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.appCard.withOpacity(0.96),
                        const Color(0xFF101C30).withOpacity(0.90),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isFocused
                          ? AppColors.appAccent
                          : AppColors.appAccent.withOpacity(0.45),
                      width: isFocused ? 1.6 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onTapOutside: (_) => focusNode.unfocus(),
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Search spaces near you...',
                      hintStyle: AppTextStyles.body
                          .copyWith(color: AppColors.grey400),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.appAccent,
                        size: 22,
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.grey500,
                                size: 18,
                              ),
                              onPressed: onClear,
                            )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: isFocused
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _SearchDropdown(
                      spaces: spaces,
                      onSelect: onSelect,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Search dropdown ──────────────────────────────────────────────────────────

class _SearchDropdown extends StatelessWidget {
  final List<SpaceModel> spaces;
  final ValueChanged<String> onSelect;

  const _SearchDropdown(
      {required this.spaces, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.appCard.withOpacity(0.96),
                  const Color(0xFF111A2A).withOpacity(0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.appAccent.withOpacity(0.24),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.32),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.appAccent.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: spaces.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 24),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          color: AppColors.grey400,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No spaces found for your search.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: spaces.length,
                    separatorBuilder: (_, __) => Divider(
                      color: AppTheme.surfaceVariant(context),
                      height: 1,
                      indent: 18,
                      endIndent: 18,
                    ),
                    itemBuilder: (_, i) {
                      final s = spaces[i];
                      return InkWell(
                        hoverColor:
                            AppColors.appAccent.withOpacity(0.08),
                        splashColor:
                            AppColors.appAccent.withOpacity(0.10),
                        highlightColor: AppColors.appAccent
                            .withOpacity(0.06),
                        onTap: () => onSelect(s.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.appAccent
                                      .withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.appAccent
                                        .withOpacity(0.20),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.appAccent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.name,
                                      style: AppTextStyles.heading3
                                          .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.address,
                                      style:
                                          AppTextStyles.bodySmall,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Map view ─────────────────────────────────────────────────────────────────

class _MapShowcaseSection extends StatelessWidget {
  final bool focused;
  final LatLng? userLocation;
  const _MapShowcaseSection({required this.focused, this.userLocation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kFloatingRiverBottomGap),
      child: SizedBox(
        height: _kHomeMapHeight + _kFloatingRiverGap + _kFloatingRiverHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 24,
              right: 24,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    _MapView(userLocation: userLocation),
                    if (focused)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: _kHomeMapHeight + _kFloatingRiverGap,
              child: _FloatingSpacesRiver(spaces: kSampleSpaces),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final LatLng? userLocation;
  const _MapView({this.userLocation});

  @override
  Widget build(BuildContext context) {
    final initialCenter = userLocation ?? const LatLng(6.925, 79.862);
    final initialZoom = userLocation != null ? 14.0 : 14.0; // could zoom closer if needed

    return Container(
      height: _kHomeMapHeight,
      decoration: AppDecorations.glassCard.copyWith(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  // ... existing space markers
                  ...kSampleSpaces.map((s) => Marker(
                        point: LatLng(s.lat, s.lng),
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () =>
                              context.read<AppProvider>().selectSpace(s.id),
                          child: const _MapMarker(),
                        ),
                      )),
                  // Add user location marker if available
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.appBg,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.appAccent.withOpacity(0.25),
        ),
      ),
      Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.appAccent,
        ),
        child: const Center(
          child: CircleAvatar(
              radius: 3, backgroundColor: Colors.white),
        ),
      ),
    ]);
  }
}

// ── Compact space card for grid ───────────────────────────────────────────────

class _FloatingSpacesRiver extends StatefulWidget {
  final List<SpaceModel> spaces;

  const _FloatingSpacesRiver({required this.spaces});

  @override
  State<_FloatingSpacesRiver> createState() => _FloatingSpacesRiverState();
}

class _FloatingSpacesRiverState extends State<_FloatingSpacesRiver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _riverCtrl;
  int? _hoveredTile;
  bool _pointerInside = false;

  @override
  void initState() {
    super.initState();
    _riverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..forward();
    _riverCtrl.addStatusListener(_handleRiverStatus);
  }

  void _handleRiverStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _riverCtrl.forward(from: 0);
    }
  }

  void _pauseRiver() {
    if (_riverCtrl.isAnimating) {
      _riverCtrl.stop(canceled: false);
    }
  }

  void _resumeRiver() {
    if (!_riverCtrl.isAnimating) {
      _riverCtrl.forward(from: _riverCtrl.value);
    }
  }

  @override
  void dispose() {
    _riverCtrl
      ..removeStatusListener(_handleRiverStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: MouseRegion(
        onEnter: (_) {
          _pointerInside = true;
          _pauseRiver();
        },
        onExit: (_) {
          _pointerInside = false;
          setState(() => _hoveredTile = null);
          _resumeRiver();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: _kFloatingRiverHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.appAccent.withOpacity(0.16),
                    AppColors.appCard.withOpacity(0.90),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.appAccent.withOpacity(0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: AppColors.appAccent.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cycleWidth =
                      widget.spaces.length * (_kRiverCardWidth + _kRiverCardGap);
                  final repeatCount =
                      ((constraints.maxWidth / cycleWidth).ceil() + 3)
                          .clamp(3, 8)
                          .toInt();
                  final tileCount = widget.spaces.length * repeatCount;
                  final trackWidth = (tileCount * _kRiverCardWidth) +
                      ((tileCount - 1) * _kRiverCardGap) +
                      28;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.bottomRight,
                              radius: 1.1,
                              colors: [
                                AppColors.appAccent.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _riverCtrl,
                        builder: (context, _) {
                          final dx =
                              -cycleWidth + (cycleWidth * _riverCtrl.value);

                          return ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.centerLeft,
                              minWidth: trackWidth,
                              maxWidth: trackWidth,
                              child: Transform.translate(
                                offset: Offset(dx, 0),
                                child: SizedBox(
                                  width: trackWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: List.generate(
                                        tileCount,
                                        (globalIndex) {
                                          final spaceIndex =
                                              globalIndex % widget.spaces.length;
                                          final isHovered =
                                              _hoveredTile == globalIndex;
                                          final hasHovered = _hoveredTile != null;

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: globalIndex == tileCount - 1
                                                  ? 0
                                                  : _kRiverCardGap,
                                            ),
                                            child: MouseRegion(
                                              onEnter: (_) {
                                                _pauseRiver();
                                                setState(
                                                  () => _hoveredTile = globalIndex,
                                                );
                                              },
                                              onExit: (_) {
                                                if (_hoveredTile == globalIndex) {
                                                  setState(() => _hoveredTile = null);
                                                }
                                                if (!_pointerInside) {
                                                  _resumeRiver();
                                                }
                                              },
                                              child: _GlassSpaceCard(
                                                space: widget.spaces[spaceIndex],
                                                isHovered: isHovered,
                                                isBackground:
                                                    hasHovered && !isHovered,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 48,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.appBg.withOpacity(0.95),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 48,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  AppColors.appBg.withOpacity(0.95),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceCardCompact extends StatelessWidget {
  final SpaceModel space;
  const _SpaceCardCompact({required this.space});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<AppProvider>().selectSpace(space.id),
      child: Container(
        decoration: AppDecorations.glassCard.copyWith(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              Image.network(space.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.appCard)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.60),
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
                        horizontal: 8, vertical: 3),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(space.name,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 12,
                            color: AppColors.appAccent),
                        const SizedBox(width: 3),
                        Text(space.rating.toStringAsFixed(1),
                            style: AppTextStyles.label.copyWith(
                                color: Colors.white)),
                      ]),
                      Row(children: [
                        const Icon(Icons.people_outline,
                            size: 12,
                            color: AppColors.appAccent2),
                        const SizedBox(width: 3),
                        Text('${space.seats}',
                            style: AppTextStyles.label),
                      ]),
                    ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _GlassSpaceCard extends StatefulWidget {
  final SpaceModel space;
  final bool isHovered;
  final bool isBackground;

  const _GlassSpaceCard({
    required this.space,
    this.isHovered = false,
    this.isBackground = false,
  });

  @override
  State<_GlassSpaceCard> createState() => _GlassSpaceCardState();
}

class _GlassSpaceCardState extends State<_GlassSpaceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final targetScale = _pressed
        ? 0.97
        : widget.isHovered
            ? 1.06
            : widget.isBackground
                ? 0.92
                : 1.0;
    final targetOffsetY = _pressed
        ? 0.02
        : widget.isHovered
            ? -0.06
            : widget.isBackground
                ? 0.035
                : 0.0;
    final targetOpacity = widget.isBackground ? 0.70 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.read<AppProvider>().selectSpace(space.id);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedSlide(
        offset: Offset(0, targetOffsetY),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: targetOpacity,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: _kRiverCardWidth,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(
                  widget.isHovered ? 0.14 : 0.10,
                ),
                border: Border.all(
                  color: widget.isHovered
                      ? AppColors.appAccent.withOpacity(0.40)
                      : Colors.white.withOpacity(0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.isBackground ? 0.12 : 0.24,
                    ),
                    blurRadius: widget.isHovered ? 28 : 18,
                    offset: Offset(0, widget.isHovered ? 18 : 10),
                  ),
                  if (widget.isHovered || _pressed)
                    BoxShadow(
                      color: AppColors.appAccent.withOpacity(0.32),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: space.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) =>
                                Container(color: AppColors.appCard),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.appCard,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(
                                    widget.isBackground ? 0.24 : 0.10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: AppColors.appAccent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  space.rating.toStringAsFixed(1),
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 12,
                                  color: AppColors.appAccent2,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${space.seats}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
