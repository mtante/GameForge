import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CyberBackground extends StatefulWidget {
  final Widget child;

  const CyberBackground({super.key, required this.child});

  @override
  State<CyberBackground> createState() => _CyberBackgroundState();
}

class _CyberBackgroundState extends State<CyberBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _GridPainter(),
          size: Size.infinite,
          child: const SizedBox.expand(),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ScanLinePainter(_controller.value),
            size: Size.infinite,
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCyan.withOpacity(0.035)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 44.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Corner brackets
    final bracketPaint = Paint()
      ..color = AppTheme.accentCyan.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const bLen = 20.0;
    const bPad = 24.0;

    // Top-left
    canvas.drawLine(const Offset(bPad, bPad), const Offset(bPad + bLen, bPad), bracketPaint);
    canvas.drawLine(const Offset(bPad, bPad), const Offset(bPad, bPad + bLen), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - bPad, bPad), Offset(size.width - bPad - bLen, bPad), bracketPaint);
    canvas.drawLine(Offset(size.width - bPad, bPad), Offset(size.width - bPad, bPad + bLen), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(bPad, size.height - bPad), Offset(bPad + bLen, size.height - bPad), bracketPaint);
    canvas.drawLine(Offset(bPad, size.height - bPad), Offset(bPad, size.height - bPad - bLen), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - bPad, size.height - bPad), Offset(size.width - bPad - bLen, size.height - bPad), bracketPaint);
    canvas.drawLine(Offset(size.width - bPad, size.height - bPad), Offset(size.width - bPad, size.height - bPad - bLen), bracketPaint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.accentCyan.withOpacity(0.0),
          AppTheme.accentCyan.withOpacity(0.05),
          AppTheme.accentCyan.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 50, size.width, 100));

    canvas.drawRect(Rect.fromLTWH(0, y - 50, size.width, 100), paint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.progress != progress;
}
