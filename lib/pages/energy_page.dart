import 'package:flutter/material.dart';
import '../main.dart';

class EnergiePage extends StatelessWidget {
  final AppState appState;
  final VoidCallback? openDrawer;
  const EnergiePage({super.key, required this.appState, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Énergie', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: openDrawer != null
            ? IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.textMuted), onPressed: openDrawer)
            : null,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (_, __) {
          final t = appState.telemetry;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Battery
                _buildCard(
                  title: '🔋  BATTERIE LiPo 3S',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            t != null ? '${t.batteryVoltage.toStringAsFixed(2)}V' : '—V',
                            style: TextStyle(
                              color: t != null ? _battColor(t.batteryVoltage) : AppColors.accent,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            t != null ? '${t.batteryPct.toStringAsFixed(0)}%' : '—%',
                            style: TextStyle(
                              color: t != null ? _battColor(t.batteryVoltage) : AppColors.textMuted,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: t != null ? (t.batteryPct / 100).clamp(0.0, 1.0) : 0,
                          minHeight: 10,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation(t != null ? _battColor(t.batteryVoltage) : AppColors.success),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'LiPo 3S 11.1V 5000mAh  ·  Seuil faible: 10.8V  ·  Critique: 10.0V',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Solar
                _buildCard(
                  title: '☀️  ÉNERGIE SOLAIRE',
                  child: Column(
                    children: [
                      _row('Tension panneau', t != null ? '${t.solarVoltage.toStringAsFixed(1)} V' : '—'),
                      _row('Puissance panneau', t != null ? '${t.solarPower.toStringAsFixed(0)} W' : '—'),
                      _row('Courant batterie', t != null ? '${t.solarCurrent.toStringAsFixed(2)} A' : '—'),
                      _row('Énergie aujourd\'hui', t != null ? '${t.solarDailyWh.toStringAsFixed(0)} Wh' : '—'),
                      _rowPill('État de charge', t?.solarState ?? '—'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Consumption
                _buildCard(
                  title: '⚡  CONSOMMATION ESTIMÉE',
                  child: Column(
                    children: [
                      _row('Raspberry Pi 5', '5–8 W'),
                      _row('Moteur brushless (croisière)', '60–100 W'),
                      _row('Caméra + IA (YOLOv8)', '2 W'),
                      _row('GPS + IMU + LEDs + Buzzer', '5.5 W'),
                      const Divider(color: AppColors.surfaceLight, height: 20),
                      _rowHighlight('Panneaux solaires (2 × 50W)', '≤ 100 W'),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _battColor(double v) {
    if (v < 10.0) return AppColors.danger;
    if (v < 10.8) return AppColors.warning;
    return AppColors.success;
  }

  Widget _row(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const Spacer(),
          Text(val, style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _rowHighlight(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(val, style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _rowPill(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Text(val, style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
