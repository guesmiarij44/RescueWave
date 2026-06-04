import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';

class ControlPage extends StatefulWidget {
  final AppState appState;
  final VoidCallback? openDrawer;
  const ControlPage({super.key, required this.appState, this.openDrawer});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool _manualMode = false;
  double _speed = 0;
  double _rudder = 0;
  Offset _knobOffset = Offset.zero;
  static const double _radius = 70.0;

  void _onJoyUpdate(Offset center, Offset touch) {
    var dx = touch.dx - center.dx;
    var dy = touch.dy - center.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist > _radius) {
      dx = dx / dist * _radius;
      dy = dy / dist * _radius;
    }
    final spd = (-dy / _radius).clamp(0.0, 1.0);
    final rud = (dx / _radius).clamp(-1.0, 1.0);
    setState(() {
      _knobOffset = Offset(dx, dy);
      _speed = spd;
      _rudder = rud;
    });
    if (_manualMode) {
      widget.appState.sendCommand({
        'type': 'manual_control',
        'speed': double.parse(spd.toStringAsFixed(2)),
        'rudder': double.parse(rud.toStringAsFixed(2)),
      });
    }
  }

  void _resetKnob() {
    setState(() {
      _knobOffset = Offset.zero;
      _speed = 0;
      _rudder = 0;
    });
    if (_manualMode) {
      widget.appState.sendCommand({'type': 'manual_control', 'speed': 0, 'rudder': 0});
    }
  }

  void _emergencyStop() {
    widget.appState.sendCommand({'type': 'emergency_stop'});
    _resetKnob();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⛔ ARRÊT D\'URGENCE envoyé!'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _returnToBase() {
    widget.appState.sendCommand({'type': 'return_home'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🏠 Retour à la base envoyé'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Contrôle', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: widget.openDrawer != null
            ? IconButton(icon: const Icon(Icons.menu_rounded, color: AppColors.textMuted), onPressed: widget.openDrawer)
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Manual mode toggle
            _buildCard(
              child: Row(
                children: [
                  const Icon(Icons.gamepad_rounded, color: AppColors.accent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('MODE MANUEL', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  Switch(
                    value: _manualMode,
                    activeColor: AppColors.accent,
                    onChanged: (v) {
                      setState(() => _manualMode = v);
                      if (!v) widget.appState.sendCommand({'type': 'manual_control', 'speed': 0, 'rudder': 0});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Joystick
            _buildCard(
              title: '🕹️  JOYSTICK',
              child: Column(
                children: [
                  Text(
                    _manualMode ? 'Glissez pour diriger le bateau' : 'Activez le mode manuel pour contrôler',
                    style: TextStyle(color: _manualMode ? AppColors.textMuted : AppColors.danger, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildJoystick(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _readout('VITESSE', '${(_speed * 100).toStringAsFixed(0)}%', AppColors.success),
                      const SizedBox(width: 12),
                      _readout('GOUVERNAIL', '${(_rudder * 100).toStringAsFixed(0)}%', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            _buildCard(
              title: '🎯  COMMANDES',
              child: Column(
                children: [
                  _actionBtn(
                    label: '🏠  RETOUR À LA BASE (POINT 0)',
                    color: AppColors.primary,
                    onTap: _returnToBase,
                  ),
                  const SizedBox(height: 10),
                  _actionBtn(
                    label: '⛔  ARRÊT D\'URGENCE',
                    color: AppColors.danger,
                    onTap: _emergencyStop,
                    border: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick() {
    const total = _radius * 2 + 40;
    return Center(
      child: LayoutBuilder(
        builder: (ctx, _) {
          return GestureDetector(
            onPanStart: (d) => _onJoyUpdate(Offset(total / 2, total / 2), d.localPosition),
            onPanUpdate: (d) => _onJoyUpdate(Offset(total / 2, total / 2), d.localPosition),
            onPanEnd: (_) => _resetKnob(),
            onPanCancel: _resetKnob,
            child: Container(
              width: total,
              height: total,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.surfaceLight, AppColors.dark]),
                border: Border.all(color: _manualMode ? AppColors.accent.withOpacity(0.6) : AppColors.surfaceLight, width: 2),
                boxShadow: _manualMode ? [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 20)] : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: _radius * 1.6,
                    height: _radius * 1.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                    ),
                  ),
                  Transform.translate(
                    offset: _knobOffset,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _manualMode
                              ? [AppColors.accent, AppColors.primary]
                              : [AppColors.surfaceLight, AppColors.surface],
                        ),
                        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 12)],
                      ),
                      child: Icon(Icons.circle, color: Colors.white.withOpacity(0.3), size: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _readout(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({required String label, required Color color, required VoidCallback onTap, bool border = false}) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: border ? color.withOpacity(0.12) : color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: border ? BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: color, width: 1.5)) : null,
            child: Center(
              child: Text(label, style: TextStyle(color: border ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
