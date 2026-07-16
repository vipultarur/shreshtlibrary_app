import 'package:flutter/material.dart';

class AnimatedScannerOverlay extends StatefulWidget {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  const AnimatedScannerOverlay({
    super.key,
    required this.borderColor,
    this.borderRadius = 12.0,
    this.borderLength = 30.0,
    this.borderWidth = 8.0,
    this.cutOutSize = 250.0,
  });

  @override
  State<AnimatedScannerOverlay> createState() => _AnimatedScannerOverlayState();
}

class _AnimatedScannerOverlayState extends State<AnimatedScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerOverlayPainter(
            borderColor: widget.borderColor,
            borderRadius: widget.borderRadius,
            borderLength: widget.borderLength,
            borderWidth: widget.borderWidth,
            cutOutSize: widget.cutOutSize,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  ScannerOverlayPainter({
    required this.borderColor,
    this.borderRadius = 12.0,
    this.borderLength = 30.0,
    this.borderWidth = 8.0,
    this.cutOutSize = 250.0,
    this.animationValue = 0.0,
  });

  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black54;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw background with cutout
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    // Draw animated scan line
    final lineY = cutOutRect.top + (cutOutRect.height * animationValue);

    // Draw the glowing gradient
    if (animationValue > 0.05) {
      final gradientHeight = 40.0;
      final gradientRect = Rect.fromLTRB(
        cutOutRect.left,
        lineY - gradientHeight,
        cutOutRect.right,
        lineY,
      );
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            borderColor.withValues(alpha: 0.0),
            borderColor.withValues(alpha: 0.3),
          ],
        ).createShader(gradientRect)
        ..blendMode = BlendMode.srcOver;

      canvas.drawRect(gradientRect.intersect(cutOutRect), gradientPaint);
    }

    // Draw the sharp scan line
    final linePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cutOutRect.left + 5, lineY),
      Offset(cutOutRect.right - 5, lineY),
      linePaint,
    );

    // Draw corners
    final path = Path();

    // Top Left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.arcToPoint(
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top Right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.arcToPoint(
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom Right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.arcToPoint(
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom Left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.arcToPoint(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderColor != borderColor;
  }
}
