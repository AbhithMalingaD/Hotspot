import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({
    super.key,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 18, size.height / 18);

    _drawPath(canvas, _buildBluePath(), _blue);
    _drawPath(canvas, _buildGreenPath(), _green);
    _drawPath(canvas, _buildYellowPath(), _yellow);
    _drawPath(canvas, _buildRedPath(), _red);

    canvas.restore();
  }

  void _drawPath(Canvas canvas, Path path, Color color) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  Path _buildBluePath() {
    return Path()
      ..moveTo(17.64, 9.2045)
      ..cubicTo(17.64, 8.5665, 17.5827, 7.9518, 17.4764, 7.3609)
      ..lineTo(9.0, 7.3609)
      ..lineTo(9.0, 10.8427)
      ..lineTo(13.8436, 10.8427)
      ..cubicTo(13.635, 11.9677, 13.0009, 12.9209, 12.0476, 13.5582)
      ..lineTo(12.0476, 15.8164)
      ..lineTo(14.9558, 15.8164)
      ..cubicTo(16.6576, 14.25, 17.64, 11.9423, 17.64, 9.2045)
      ..close();
  }

  Path _buildGreenPath() {
    return Path()
      ..moveTo(9.0, 18.0)
      ..cubicTo(11.43, 18.0, 13.4673, 17.194, 14.9564, 15.8164)
      ..lineTo(12.0482, 13.5582)
      ..cubicTo(11.2418, 14.0982, 10.2114, 14.4173, 9.0, 14.4173)
      ..cubicTo(6.6523, 14.4173, 4.6659, 12.8314, 3.9568, 10.7009)
      ..lineTo(0.9577, 10.7009)
      ..lineTo(0.9577, 13.0327)
      ..cubicTo(2.4382, 15.975, 5.4818, 18.0, 9.0, 18.0)
      ..close();
  }

  Path _buildYellowPath() {
    return Path()
      ..moveTo(3.9568, 10.7009)
      ..cubicTo(3.7761, 10.1609, 3.6727, 9.5841, 3.6727, 9.0)
      ..cubicTo(3.6727, 8.4159, 3.7761, 7.8391, 3.9568, 7.2991)
      ..lineTo(3.9568, 4.9673)
      ..lineTo(0.9577, 4.9673)
      ..cubicTo(0.3477, 6.1823, 0.0, 7.5505, 0.0, 9.0)
      ..cubicTo(0.0, 10.4495, 0.3477, 11.8177, 0.9577, 13.0327)
      ..lineTo(3.9568, 10.7009)
      ..close();
  }

  Path _buildRedPath() {
    return Path()
      ..moveTo(9.0, 3.5836)
      ..cubicTo(10.3214, 3.5836, 11.5077, 4.0377, 12.4405, 4.9286)
      ..lineTo(15.0218, 2.3477)
      ..cubicTo(13.4636, 0.8982, 11.4259, 0.0, 9.0, 0.0)
      ..cubicTo(5.4818, 0.0, 2.4382, 2.025, 0.9577, 4.9673)
      ..lineTo(3.9568, 7.2991)
      ..cubicTo(4.6659, 5.1695, 6.6523, 3.5836, 9.0, 3.5836)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
