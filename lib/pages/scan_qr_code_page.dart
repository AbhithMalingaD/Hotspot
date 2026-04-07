import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class ScanQRCodePage extends StatefulWidget {
  const ScanQRCodePage({super.key});

  @override
  State<ScanQRCodePage> createState() => _ScanQRCodePageState();
}

class _ScanQRCodePageState extends State<ScanQRCodePage>
    with SingleTickerProviderStateMixin {
  String _state = 'scanning'; // scanning | valid | invalid
  late final AnimationController _scanAnim;
  late final Animation<double> _scanPos;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanPos =
        Tween<double>(begin: 0, end: 1).animate(_scanAnim);
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFEFF2F7),
      body: Stack(children: [
        // ── Dotted grid + radial gradient background ─────────────────
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF0D1B2A), Colors.black]
                  : [const Color(0xFFE2E8F0), const Color(0xFFF8FAFC)],
              radius: 1.2,
            ),
          ),
          child: CustomPaint(
            painter: _DottedGridPainter(isDark: isDark),
            child: const SizedBox.expand(),
          ),
        ),

        SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black87),
                  onPressed: () => context
                      .read<AppProvider>()
                      .setScanQROpen(false),
                ),
                Expanded(
                  child: Text('Scan QR Code',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87)),
                ),
                const SizedBox(width: 48),
              ]),
            ),

            const SizedBox(height: 32),
            Text('Align QR code within the frame',
                style: AppTextStyles.body.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // Scanner frame
            Center(
              child: SizedBox(
                width: 256,
                height: 256,
                child: Stack(children: [
                  // Corners
                  _Corner2(
                      top: true, left: true, isDark: isDark),
                  _Corner2(
                      top: true, left: false, isDark: isDark),
                  _Corner2(
                      top: false, left: true, isDark: isDark),
                  _Corner2(
                      top: false, left: false, isDark: isDark),

                  // Scan line
                  if (_state == 'scanning')
                    AnimatedBuilder(
                      animation: _scanPos,
                      builder: (_, __) => Positioned(
                        top: _scanPos.value * 248,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            color: AppColors.adminAccent,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.adminAccent,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Mock QR icon
                  Center(
                    child: Icon(Icons.qr_code_2_rounded,
                        size: 180,
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08)),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 40),

            // Demo buttons
            if (_state == 'scanning')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DemoBtn(
                    label: 'Simulate Valid',
                    color: AppColors.appAccent,
                    onTap: () => setState(() => _state = 'valid'),
                  ),
                  const SizedBox(width: 12),
                  _DemoBtn(
                    label: 'Simulate Invalid',
                    color: AppColors.red400,
                    onTap: () =>
                        setState(() => _state = 'invalid'),
                  ),
                ],
              ),
          ]),
        ),

        // Result sheet
        if (_state != 'scanning')
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ResultSheet(
              valid: _state == 'valid',
              onScanAgain: () =>
                  setState(() => _state = 'scanning'),
              onCheckin: () => context
                  .read<AppProvider>()
                  .setScanQROpen(false),
              isDark: isDark,
            ),
          ),
      ]),
    );
  }
}

// ── Dotted grid painter (theme‑aware) ─────────────────────────────────────
class _DottedGridPainter extends CustomPainter {
  final bool isDark;
  const _DottedGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.08)
      ..strokeWidth = 1;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Corner2 extends StatelessWidget {
  final bool top, left;
  final bool isDark;
  const _Corner2({
    required this.top,
    required this.left,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(
          painter: _CornerPainter2(
              top: top,
              left: left,
              color: AppColors.adminAccent,
              isDark: isDark),
        ),
      ),
    );
  }
}

class _CornerPainter2 extends CustomPainter {
  final bool top, left;
  final Color color;
  final bool isDark;
  _CornerPainter2({
    required this.top,
    required this.left,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 4
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
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DemoBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DemoBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? color : Colors.black87)),
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final bool valid;
  final VoidCallback onScanAgain;
  final VoidCallback onCheckin;
  final bool isDark;
  const _ResultSheet({
    required this.valid,
    required this.onScanAgain,
    required this.onCheckin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
      decoration: BoxDecoration(
        color: valid
            ? AppColors.appAccent.withOpacity(0.10)
            : AppColors.red400.withOpacity(0.10),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: valid
                ? AppColors.appAccent.withOpacity(0.30)
                : AppColors.red400.withOpacity(0.30),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valid
                  ? AppColors.appAccent.withOpacity(0.20)
                  : AppColors.red400.withOpacity(0.20),
            ),
            child: Icon(
              valid
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              size: 32,
              color: valid ? AppColors.appAccent : AppColors.red400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            valid ? 'Valid Check-in' : 'Invalid QR Code',
            style: AppTextStyles.heading2.copyWith(
                color: valid ? AppColors.appAccent : AppColors.red400),
          ),
          const SizedBox(height: 8),
          if (valid) ...[
            Text('Kasun Perera',
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87)),
            Text('Hot Desk · 2:00 PM – 5:00 PM',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheckin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Mark as Checked In',
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ] else ...[
            Text('Reason: Code already used or expired',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onScanAgain,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.20)
                          : Colors.black.withOpacity(0.20)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Scan Again',
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}