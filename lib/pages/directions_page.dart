import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class DirectionsPage extends StatefulWidget {
  const DirectionsPage({super.key});

  @override
  State<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
  String _mode = 'walk';

  // User's current location (slightly north of destination)
  static const _userLoc  = LatLng(6.9310, 79.8650);
  // Destination: Urban Hub, 123 Galle Road
  static const _destLoc  = LatLng(6.9271, 79.8612);
  // Map centre — midpoint between user and destination
  static const _mapCenter = LatLng(6.9291, 79.8631);

  // Route polyline points
  static const _routePoints = [
    LatLng(6.9310, 79.8650),
    LatLng(6.9305, 79.8645),
    LatLng(6.9298, 79.8638),
    LatLng(6.9290, 79.8628),
    LatLng(6.9282, 79.8620),
    LatLng(6.9275, 79.8615),
    LatLng(6.9271, 79.8612),
  ];

  static const _walkSteps = [
    _StepData('Start at your current location', '0 km',    Icons.my_location_rounded),
    _StepData('Head north on Main Street',       '0.3 km', Icons.navigation_rounded),
    _StepData('Turn right onto Galle Road',      '0.5 km', Icons.turn_right_rounded),
    _StepData('Continue straight for 200 m',     '0.2 km', Icons.straight_rounded),
    _StepData('Turn left onto Union Lane',        '0.1 km', Icons.turn_left_rounded),
    _StepData('Destination on the right',         '0.1 km', Icons.location_on_rounded),
  ];

  static const _driveSteps = [
    _StepData('Start at your current location',   '0 km',  Icons.my_location_rounded),
    _StepData('Head north on Main Street',        '0.8 km', Icons.navigation_rounded),
    _StepData('Turn right onto Galle Road',       '1.2 km', Icons.turn_right_rounded),
    _StepData('Take the 2nd exit at roundabout',  '0.3 km', Icons.roundabout_left_rounded),
    _StepData('Destination on the left',          '0.2 km', Icons.location_on_rounded),
  ];

  List<_StepData> get _steps => _mode == 'walk' ? _walkSteps : _driveSteps;

  Future<void> _openExternalMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${_destLoc.latitude},${_destLoc.longitude}'
      '&travelmode=${_mode == 'walk' ? 'walking' : 'driving'}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final mapH = screenH * 0.48;
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(children: [
        // Map
        SizedBox(
          height: mapH,
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 14.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolylineLayer(polylines: [
                Polyline(
                  points: _routePoints,
                  color: AppColors.appAccent.withOpacity(0.25),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
                Polyline(
                  points: _routePoints,
                  color: AppColors.appAccent,
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  isDotted: true,
                ),
              ]),
              MarkerLayer(markers: [
                Marker(
                  point: _userLoc,
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.18),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.45), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const Marker(
                  point: _destLoc,
                  width: 36,
                  height: 36,
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.appAccent,
                    size: 36,
                  ),
                ),
              ]),
            ],
          ),
        ),
        // Back button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () =>
                  context.read<AppProvider>().setDirectionsOpen(false),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.dividerColor(context)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        // Open in Maps button
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _openExternalMaps,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.dividerColor(context)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.open_in_new_rounded,
                        size: 13, color: AppColors.appAccent),
                    const SizedBox(width: 6),
                    Text('Maps',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.appAccent,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ),
        ),
        // Bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: mapH - 24,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                  top: BorderSide(color: AppTheme.dividerColor(context))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urban Hub',
                          style: AppTextStyles.heading2.copyWith(
                              color: AppTheme.textPrimary(context))),
                      const SizedBox(height: 2),
                      Text('123 Galle Road, Colombo 03',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: _ModeBtn(
                            label: 'Walking',
                            icon: Icons.directions_walk_rounded,
                            active: _mode == 'walk',
                            onTap: () => setState(() => _mode = 'walk'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeBtn(
                            label: 'Driving',
                            icon: Icons.directions_car_rounded,
                            active: _mode == 'drive',
                            onTap: () => setState(() => _mode = 'drive'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        Text(
                          _mode == 'walk' ? '15' : '5',
                          style: AppTextStyles.heading1
                              .copyWith(fontSize: 36, color: AppTheme.textPrimary(context)),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('min',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppTheme.textSecondary(context))),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _mode == 'walk' ? '(1.2 km)' : '(2.5 km)',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.appAccent),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _openExternalMaps,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.appAccent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.navigation_rounded,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Start',
                                      style: AppTextStyles.label
                                          .copyWith(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 12)),
                                ]),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      Text('Directions',
                          style: AppTextStyles.heading3.copyWith(
                              color: AppTheme.textPrimary(context))),
                      const SizedBox(height: 14),
                      ..._steps.skip(1).toList().asMap().entries.map((e) {
                        final i = e.key;
                        final step = e.value;
                        final isRight = i.isOdd;
                        return _DirectionStepCard(
                          step: step,
                          alignRight: isRight,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _DirectionStepCard extends StatelessWidget {
  final _StepData step;
  final bool alignRight;

  const _DirectionStepCard({
    required this.step,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor(context)),
      ),
      child: Text(
        step.instruction,
        style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500, fontSize: 13, color: AppTheme.textPrimary(context)),
      ),
    );

    final icon = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.appAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.appAccent.withOpacity(0.30)),
      ),
      child: Icon(step.icon,
          size: 14, color: AppColors.appAccent),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: alignRight
          ? [
              const Spacer(),
              Expanded(flex: 5, child: card),
              const SizedBox(width: 8),
              icon,
            ]
          : [
              icon,
              const SizedBox(width: 8),
              Expanded(flex: 5, child: card),
              const Spacer(),
            ],
    );
  }
}

class _StepData {
  final String instruction;
  final String distance;
  final IconData icon;
  const _StepData(this.instruction, this.distance, this.icon);
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active
              ? AppColors.appAccent.withOpacity(0.18)
              : AppTheme.surfaceVariant(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.appAccent.withOpacity(0.40)
                : AppTheme.dividerColor(context),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: active ? AppColors.appAccent : AppTheme.textSecondary(context)),
            const SizedBox(width: 7),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: active ? AppColors.appAccent : AppTheme.textSecondary(context),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}