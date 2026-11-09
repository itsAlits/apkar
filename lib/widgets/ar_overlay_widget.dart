import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../screens/ar_screen.dart';
import '../theme/app_theme.dart';
import '../models/balinese_mask.dart';
import 'model3d_viewer_widget.dart';

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

        // Clean Yellow Scan Line (scanning only)
        if (arState == ARState.scanning) _buildScanLine(size),

        // === SCANNING: mandala kecil di tengah ===
        if (arState == ARState.scanning) _buildScanningMandala(size),

        // === DETECTED & seterusnya: model 3D besar + HUD ===
        if (arState != ARState.scanning) _buildFullScreenModelDisplay(size),
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

  /// Mandala kecil di tengah saat mode scanning
  Widget _buildScanningMandala(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.42;

    return AnimatedBuilder(
      animation: Listenable.merge([rotateAnimation, pulseAnimation]),
      builder: (context, child) {
        return Positioned(
          left: centerX - 60,
          top: centerY - 60,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: rotateAnimation.value,
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: BalineseMandalaOverlayPainter(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      petals: 8,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -rotateAnimation.value * 0.7,
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: BalineseMandalaOverlayPainter(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      strokeWidth: 1.2,
                      petals: 6,
                    ),
                  ),
                ),
                Text(
                  mask?.emoji ?? '🎭',
                  style: const TextStyle(fontSize: 36),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Layout utama saat topeng terdeteksi — model 3D besar + HUD
  Widget _buildFullScreenModelDisplay(Size size) {
    // Tinggi area model: dari bawah topbar (~100px) sampai atas bottom controls (~180px)
    final topBarHeight = size.height * 0.14;
    final bottomControlHeight = size.height * 0.26;
    final modelAreaHeight = size.height - topBarHeight - bottomControlHeight;
    final modelAreaWidth = size.width;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // ── Model 3D besar di tengah layar ──────────────────────────
            Positioned(
              top: topBarHeight,
              left: 0,
              right: 0,
              height: modelAreaHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Mandala ring tipis di atas model sebagai dekorasi AR
                    SizedBox(
                      height: 24,
                      child: AnimatedBuilder(
                        animation: rotateAnimation,
                        builder: (context, _) => CustomPaint(
                          size: Size(modelAreaWidth, 24),
                          painter: HorizontalLinePainter(
                            color: AppTheme.primaryColor.withValues(alpha: 0.4 * pulseAnimation.value),
                          ),
                        ),
                      ),
                    ),

                    // Model 3D / emoji — mengisi sisa area
                    Expanded(
                      child: mask != null && mask!.hasModel3D
                          ? _build3DModelViewer(mask!)
                          : Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX(userRotationX)
                                ..rotateY(userRotationY),
                              alignment: Alignment.center,
                              child: _buildLargeEmojiDisplay(mask),
                            ),
                    ),

                    // Garis bawah + nama topeng
                    _buildModelLabel(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── HUD panel kiri & kanan ──────────────────────────────────
            if (arState == ARState.detected || arState == ARState.responding)
              _buildHUDPanels(size),
          ],
        );
      },
    );
  }

  Widget _build3DModelViewer(BalineseMask m) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Model3DViewerWidget(
        mask: m,
        height: double.infinity,
        autoRotate: true,
        showLabel: false,
      ),
    );
  }

  Widget _buildLargeEmojiDisplay(BalineseMask? m) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              m?.emoji ?? '🎭',
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 12),
            Text(
              m?.name ?? 'Topeng Bali',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Model 3D belum tersedia',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelLabel() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3 * pulseAnimation.value),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mask?.hasModel3D == true ? Icons.view_in_ar : Icons.emoji_emotions_outlined,
              color: AppTheme.primaryColor,
              size: 13,
            ),
            const SizedBox(width: 7),
            Text(
              mask?.hasModel3D == true
                  ? '${mask!.name} · Putar & Zoom'
                  : (mask?.name ?? 'Topeng Bali'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
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

class HorizontalLinePainter extends CustomPainter {
  final Color color;

  HorizontalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    canvas.drawLine(Offset(20, centerY), Offset(size.width - 20, centerY), paint);
    canvas.drawCircle(Offset(size.width / 2, centerY), 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant HorizontalLinePainter oldDelegate) =>
      oldDelegate.color != color;
}



