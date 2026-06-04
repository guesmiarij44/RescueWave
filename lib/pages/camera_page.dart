import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../main.dart';

class CameraPage extends StatelessWidget {
  final AppState appState;
  final VoidCallback? openDrawer;
  const CameraPage({super.key, required this.appState, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Caméra', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: openDrawer != null
            ? IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.textMuted), onPressed: openDrawer)
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
            tooltip: 'Demander snapshot',
            onPressed: () {
              appState.sendCommand({'type': 'get_snapshot'});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📸 Snapshot demandé…'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          final frame = appState.telemetry?.cameraFrame;
          return Column(
            children: [
              // Video feed
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: frame != null ? AppColors.danger : AppColors.surfaceLight, width: 1.5),
                    boxShadow: frame != null ? [BoxShadow(color: AppColors.danger.withOpacity(0.15), blurRadius: 20)] : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (frame != null)
                          _CameraFrame(base64: frame)
                        else
                          const _NoFeedPlaceholder(),
                        // Overlay badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _LiveBadge(isLive: frame != null),
                        ),
                        if (frame != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('AI ACTIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Info panel
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _infoChip(Icons.videocam_rounded, 'Caméra RPi', AppColors.accent),
                        const SizedBox(width: 10),
                        _infoChip(Icons.psychology_rounded, 'YOLOv8 IA', AppColors.success),
                        const SizedBox(width: 10),
                        _infoChip(Icons.hd_rounded, '1080p', AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            frame != null
                                ? 'Flux vidéo en direct. Détection IA en cours.'
                                : 'En attente du flux vidéo du Raspberry Pi…\nLe bateau doit être connecté à Firebase.',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CameraFrame extends StatelessWidget {
  final String base64;
  const _CameraFrame({required this.base64});

  @override
  Widget build(BuildContext context) {
    try {
      final Uint8List bytes = base64Decode(base64);
      return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } catch (_) {
      return const _NoFeedPlaceholder();
    }
  }
}

class _NoFeedPlaceholder extends StatelessWidget {
  const _NoFeedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060c14),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded, size: 56, color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('En attente du flux vidéo…', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('HORS LIGNE', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLive;
  const _LiveBadge({required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLive ? AppColors.danger : Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            isLive ? 'EN DIRECT' : 'HORS LIGNE',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
