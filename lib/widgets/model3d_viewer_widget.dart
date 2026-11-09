import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/balinese_mask.dart';
import '../theme/app_theme.dart';

/// Widget untuk menampilkan model 3D GLB menggunakan ModelViewer.
/// Jika model belum tersedia, tampilkan fallback emoji bergaya AR.
class Model3DViewerWidget extends StatelessWidget {
  final BalineseMask mask;
  final double height;
  final bool autoRotate;
  final bool showLabel;

  const Model3DViewerWidget({
    super.key,
    required this.mask,
    this.height = 280,
    this.autoRotate = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // ── 3D Model Viewer ───────────────────────────────────────────
          if (mask.hasModel3D)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF0D0F14),
                child: ModelViewer(
                  src: mask.modelAssetPath,
                  alt: mask.name,
                  autoRotate: autoRotate,
                  autoPlay: true,
                  cameraControls: true,
                  disableZoom: false,
                  backgroundColor: const Color(0xFF0D0F14),
                  loading: Loading.eager,
                  exposure: 1.2,
                ),
              ),
            )
          // ── Fallback: animated emoji placeholder ──────────────────────
          else
            _buildFallbackView(),

          // ── Label overlay ─────────────────────────────────────────────
          if (showLabel)
            Positioned(
              bottom: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mask.hasModel3D
                          ? Icons.view_in_ar
                          : Icons.image_not_supported_outlined,
                      color: AppTheme.primaryColor,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      mask.hasModel3D ? 'Model 3D · Putar & Zoom' : 'Preview 2D · Model 3D segera',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackView() {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(mask.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 10),
          Text(
            mask.name,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Model 3D belum tersedia',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Versi compact untuk AR Overlay (menggantikan emoji 🎭 di tengah mandala)
class Model3DCompactViewer extends StatelessWidget {
  final BalineseMask mask;
  final double size;

  const Model3DCompactViewer({
    super.key,
    required this.mask,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (!mask.hasModel3D) {
      // Fallback: emoji dengan background circle
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mask.emoji, style: TextStyle(fontSize: size * 0.4)),
            Text(
              mask.name.replaceAll('Topeng ', ''),
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
      );
    }

    // Viewer 3D sesungguhnya dalam bentuk square
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: ModelViewer(
          src: mask.modelAssetPath,
          alt: mask.name,
          autoRotate: true,
          cameraControls: false,
          disableZoom: true,
          backgroundColor: const Color(0xFF0D0F14),
          exposure: 1.0,
        ),
      ),
    );
  }
}
