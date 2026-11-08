import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../screens/ar_screen.dart';
import '../theme/app_theme.dart';
import '../models/balinese_mask.dart';

class AROverlayWidget extends StatelessWidget {
  final ARState arState;
  final Animation<double> scanLineAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;
  final double userRotationX;
  final double userRotationY;
  final BalineseMask? mask;

  const AROverlayWidget({
    super.key,
    required this.arState,
    required this.scanLineAnimation,
    required this.pulseAnimation,
    required this.rotateAnimation,
    this.userRotationX = 0.0,
    this.userRotationY = 0.0,
    this.mask,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Balinese Corner Brackets
        _buildBalineseCornerBrackets(size),

        // Clean Yellow Scan Line
        if (arState == ARState.scanning) _buildScanLine(size),

        // AR Target & 3D Balinese Mask Hologram
        if (arState != ARState.scanning) _buildBalineseMaskTarget(size),

        // Balinese HUD Data Panels
        if (arState == ARState.detected || arState == ARState.responding)
          _buildHUDPanels(size),
      ],
    );
  }

  Widget _buildBalineseCornerBrackets(Size size) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: BalineseCornerPainter(
            color: AppTheme.primaryColor.withValues(
              alpha: 0.7 * pulseAnimation.value,
            ),
            bracketSize: 32,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildScanLine(Size size) {
    return AnimatedBuilder(
      animation: scanLineAnimation,
      builder: (context, child) {
        final y = size.height * scanLineAnimation.value;
        return Positioned(
          top: y,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color: AppTheme.primaryColor.withValues(alpha: 0.8),
          ),
        );
      },
    );
  }

  Widget _buildBalineseMaskTarget(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.40;

    return AnimatedBuilder(
      animation: Listenable.merge([rotateAnimation, pulseAnimation]),
      builder: (context, child) {
        return Positioned(
          left: centerX - 90,
          top: centerY - 90,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(userRotationX)
              ..rotateY(userRotationY),
            alignment: Alignment.center,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Yellow Mandala Ring
                  Transform.rotate(
                    angle: rotateAnimation.value,
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: BalineseMandalaOverlayPainter(
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                        strokeWidth: 1.5,
                        petals: 8,
                      ),
                    ),
                  ),
                  // Inner Yellow Ring
                  Transform.rotate(
                    angle: -rotateAnimation.value * 0.6,
                    child: CustomPaint(
                      size: const Size(130, 130),
                      painter: BalineseMandalaOverlayPainter(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        strokeWidth: 1.2,
                        petals: 6,
                      ),
                    ),
                  ),
                  // Center 3D Balinese Mask Hologram Container
                  Transform.scale(
                    scale: pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceColor,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🎭',
                            style: TextStyle(fontSize: 32),
                          ),
                          Text(
                            mask != null
                                ? mask!.name.replaceAll('Topeng ', '')
                                : '3D TOPENG',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHUDPanels(Size size) {
    final maskName = mask?.name ?? 'Topeng Tradisional Bali';
    final maskChar = mask?.characterType ?? 'Sakral / Wali';

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top-left data panel
            Positioned(
              top: size.height * 0.16,
              left: 16,
              child: _buildHUDPanel(
                label: 'TAKSU TOPENG',
                value: maskName.replaceAll('Topeng ', '').toUpperCase(),
                opacity: pulseAnimation.value,
              ),
            ),
            // Top-right data panel
            Positioned(
              top: size.height * 0.16,
              right: 16,
              child: _buildHUDPanel(
                label: 'KARAKTER',
                value: maskChar.split(' ').first.toUpperCase(),
                opacity: pulseAnimation.value,
              ),
            ),
            // Bottom data strip
            Positioned(
              bottom: size.height * 0.35,
              left: 18,
              right: 18,
              child: _buildHUDStrip(opacity: pulseAnimation.value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHUDPanel({
    required String label,
    required String value,
    required double opacity,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.4 * opacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor.withValues(alpha: 0.8 * opacity),
              fontSize: 8.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95 * opacity),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUDStrip({required double opacity}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25 * opacity),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStripItem('BAHAN', 'KAYU PULE', opacity),
          _buildStripDivider(),
          _buildStripItem('KOSMOLOGI', 'RWA BHINEDA', opacity),
          _buildStripDivider(),
          _buildStripItem('INTERAKSI', 'PUTAR 360°', opacity),
        ],
      ),
    );
  }

  Widget _buildStripItem(String key, String val, double opacity) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          style: TextStyle(
            color: Colors.white38.withValues(alpha: 0.6 * opacity),
            fontSize: 8,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: AppTheme.primaryColor.withValues(alpha: 0.9 * opacity),
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStripDivider() {
    return Container(
      width: 1,
      height: 18,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class BalineseCornerPainter extends CustomPainter {
  final Color color;
  final double bracketSize;
  final double strokeWidth;

  BalineseCornerPainter({
    required this.color,
    required this.bracketSize,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final margin = 20.0;
    final w = size.width;
    final h = size.height;
    final b = bracketSize;

    // Top-Left
    canvas.drawLine(Offset(margin, margin + b), Offset(margin, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + b, margin), paint);

    // Top-Right
    canvas.drawLine(
      Offset(w - margin - b, margin),
      Offset(w - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(w - margin, margin),
      Offset(w - margin, margin + b),
      paint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(margin, h - margin - b),
      Offset(margin, h - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, h - margin),
      Offset(margin + b, h - margin),
      paint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(w - margin - b, h - margin),
      Offset(w - margin, h - margin),
      paint,
    );
    canvas.drawLine(
      Offset(w - margin, h - margin),
      Offset(w - margin, h - margin - b),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BalineseMandalaOverlayPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int petals;

  BalineseMandalaOverlayPainter({
    required this.color,
    required this.strokeWidth,
    required this.petals,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    canvas.drawCircle(center, radius, paint);

    final angleStep = (2 * math.pi) / petals;
    for (int i = 0; i < petals; i++) {
      final angle = i * angleStep;
      final x = center.dx + radius * 0.85 * math.cos(angle);
      final y = center.dy + radius * 0.85 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
