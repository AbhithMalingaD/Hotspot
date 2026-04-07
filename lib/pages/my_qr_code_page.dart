import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class MyQRCodePage extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;
  const MyQRCodePage({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final details = bookingDetails;
    final isActive = details['status'] == 'Active';
    final spaceName = details['spaceName'] ?? 'Urban Hub';
    final unitType  = details['unitType']  ?? 'Hot Desk';
    final checkIn   = details['checkIn']   ?? '09:00 AM';
    final checkOut  = details['checkOut']  ?? '12:00 PM';
    final expiresIn = details['expiresIn'] ?? '2h 45m';
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () =>
                    context.read<AppProvider>().setSelectedQRCode(null),
              ),
              Expanded(
                child: Text('My QR Code',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
              ),
              const SizedBox(width: 48),
            ]),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppTheme.dividerColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.appAccent.withOpacity(0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.appAccent.withOpacity(0.20) : AppTheme.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: isActive ? AppColors.appAccent.withOpacity(0.30) : AppTheme.dividerColor(context),
                          ),
                        ),
                        child: Text(
                          (details['status'] ?? 'Active').toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: isActive ? AppColors.appAccent : AppTheme.textSecondary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Opacity(
                        opacity: isActive ? 1.0 : 0.40,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.appAccent.withOpacity(0.20),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              QrImageView(
                                data: 'HOTSPOT::BOOKING::${spaceName.toUpperCase().replaceAll(' ', '-')}::EXP::2026-03-19T17:00:00',
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                              ),
                              ..._buildCorners(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(spaceName,
                          style: AppTextStyles.heading2.copyWith(color: AppTheme.textPrimary(context))),
                      Text(unitType,
                          style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.dividerColor(context)),
                        ),
                        child: Column(children: [
                          _QRDetailRow(
                            icon: Icons.access_time_rounded,
                            text: '$checkIn — $checkOut',
                          ),
                          const SizedBox(height: 10),
                          const _QRDetailRow(
                            icon: Icons.location_on_outlined,
                            text: 'Show at reception',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isActive ? 'Expires in $expiresIn' : 'Expired',
                        style: AppTextStyles.body.copyWith(
                          color: isActive ? AppColors.appAccent : AppColors.red400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Text(
              'Show this QR code to the space admin at check-in.',
              style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const c = AppColors.appAccent;
    const t = 4.0;
    const s = 20.0;
    return [
      const Positioned(top: 0, left: 0, child: _Corner(c, t, s, true, true)),
      const Positioned(top: 0, right: 0, child: _Corner(c, t, s, true, false)),
      const Positioned(bottom: 0, left: 0, child: _Corner(c, t, s, false, true)),
      const Positioned(bottom: 0, right: 0, child: _Corner(c, t, s, false, false)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double thickness, size;
  final bool top, left;
  const _Corner(this.color, this.thickness, this.size, this.top, this.left);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(color: color, thickness: thickness, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top, left;

  _CornerPainter({required this.color, required this.thickness, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _QRDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _QRDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Row(children: [
      Icon(icon, size: 15, color: AppColors.appAccent2),
      const SizedBox(width: 10),
      Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
    ]);
  }
}