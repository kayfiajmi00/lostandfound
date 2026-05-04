import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// The NSU Recovery logo — the orange rounded-square with magnifier icon
/// Can be used as splash, login header, or app bar brand
class NsuLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkText;
  const NsuLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.darkText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _LogoMark(size: size),
      if (showText) ...[
        const SizedBox(height: 14),
        Text('NSU Recovery',
          style: GoogleFonts.nunitoSans(
            color: darkText ? AppColors.textPrimary : Colors.white,
            fontSize: size * 0.30,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          )),
        const SizedBox(height: 3),
        Text('Lost & Found Platform',
          style: GoogleFonts.nunitoSans(
            color: darkText ? AppColors.textMuted : Colors.white70,
            fontSize: size * 0.16,
            fontWeight: FontWeight.w400,
          )),
      ],
    ]);
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.30),
          blurRadius: size * 0.35,
          offset: Offset(0, size * 0.10),
        )],
      ),
      child: CustomPaint(
        painter: _MagnifierPainter(size: size),
      ),
    );
  }
}

class _MagnifierPainter extends CustomPainter {
  final double size;
  _MagnifierPainter({required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.09
      ..strokeCap = StrokeCap.round;

    final cx = s.width * 0.44;
    final cy = s.height * 0.42;
    final r  = s.width * 0.22;

    // Circle
    canvas.drawCircle(Offset(cx, cy), r, p);

    // Handle
    final start = Offset(cx + r * 0.7, cy + r * 0.7);
    final end   = Offset(s.width * 0.80, s.height * 0.80);
    canvas.drawLine(start, end, p);

    // Dot inside circle (location pin feel)
    final dotP = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r * 0.12), size * 0.055, dotP);
  }

  @override
  bool shouldRepaint(_) => false;
}
