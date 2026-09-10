import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models/enums.dart';
import 'common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VehicleDiagram — Top-view SVG-style wheel diagram with status indicators
// ─────────────────────────────────────────────────────────────────────────────
class VehicleDiagram extends StatelessWidget {
  final AlignmentStatus flStatus;
  final AlignmentStatus frStatus;
  final AlignmentStatus rlStatus;
  final AlignmentStatus rrStatus;

  const VehicleDiagram({
    super.key,
    required this.flStatus,
    required this.frStatus,
    required this.rlStatus,
    required this.rrStatus,
  });

  Color _statusColor(AlignmentStatus s) {
    switch (s) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _VehiclePainter(
          flColor: _statusColor(flStatus),
          frColor: _statusColor(frStatus),
          rlColor: _statusColor(rlStatus),
          rrColor: _statusColor(rrStatus),
        ),
        child: Stack(
          children: [
            // Wheel labels
            Positioned(top: 18, left: 26, child: _WheelLabel('FL', flStatus)),
            Positioned(top: 18, right: 26, child: _WheelLabel('FR', frStatus)),
            Positioned(bottom: 18, left: 26, child: _WheelLabel('RL', rlStatus)),
            Positioned(bottom: 18, right: 26, child: _WheelLabel('RR', rrStatus)),
          ],
        ),
      ),
    );
  }
}

class _WheelLabel extends StatelessWidget {
  final String label;
  final AlignmentStatus status;

  const _WheelLabel(this.label, this.status);

  Color get _color {
    switch (status) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          status.label,
          style: TextStyle(color: _color.withOpacity(0.8), fontSize: 9),
        ),
      ],
    );
  }
}

class _VehiclePainter extends CustomPainter {
  final Color flColor, frColor, rlColor, rrColor;

  _VehiclePainter({
    required this.flColor,
    required this.frColor,
    required this.rlColor,
    required this.rrColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Car body
    final bodyPaint = Paint()
      ..color = AppColors.surface2
      ..style = PaintingStyle.fill;
    final bodyBorderPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 80, height: 130),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, bodyBorderPaint);

    // Windshield lines
    final windshieldPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 28), width: 52, height: 20),
        const Radius.circular(4),
      ),
      windshieldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 28), width: 52, height: 18),
        const Radius.circular(4),
      ),
      windshieldPaint,
    );

    // Center line
    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx, cy - 50), Offset(cx, cy + 50), linePaint);

    // Axle lines
    canvas.drawLine(Offset(cx - 55, cy - 42), Offset(cx + 55, cy - 42), linePaint);
    canvas.drawLine(Offset(cx - 55, cy + 42), Offset(cx + 55, cy + 42), linePaint);

    // Draw wheels
    _drawWheel(canvas, Offset(cx - 55, cy - 42), flColor);
    _drawWheel(canvas, Offset(cx + 55, cy - 42), frColor);
    _drawWheel(canvas, Offset(cx - 55, cy + 42), rlColor);
    _drawWheel(canvas, Offset(cx + 55, cy + 42), rrColor);
  }

  void _drawWheel(Canvas canvas, Offset center, Color color) {
    // Tire
    final tirePaint = Paint()
      ..color = AppColors.surface3
      ..style = PaintingStyle.fill;
    final tireBorder = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const tireRect = Rect.fromLTWH(-12, -20, 24, 40);
    final tireRRect = RRect.fromRectAndRadius(
      tireRect.shift(center),
      const Radius.circular(5),
    );
    canvas.drawRRect(tireRRect, tirePaint);
    canvas.drawRRect(tireRRect, tireBorder);

    // Rim
    final rimPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 14, height: 32),
      rimPaint,
    );

    // Status glow dot
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, 8, glowPaint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_VehiclePainter old) =>
      old.flColor != flColor ||
      old.frColor != frColor ||
      old.rlColor != rlColor ||
      old.rrColor != rrColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// AlignmentStatusCard
// ─────────────────────────────────────────────────────────────────────────────
class AlignmentStatusCard extends StatelessWidget {
  final AlignmentStatus status;

  const AlignmentStatusCard({super.key, required this.status});

  Color get _color {
    switch (status) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  IconData get _icon {
    switch (status) {
      case AlignmentStatus.normal: return Icons.check_circle_outline;
      case AlignmentStatus.warning: return Icons.warning_amber_outlined;
      case AlignmentStatus.critical: return Icons.error_outline;
      case AlignmentStatus.unavailable: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withOpacity(0.12),
            _color.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _color.withOpacity(0.5)),
            ),
            child: Icon(_icon, color: _color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Alignment',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.label,
                  style: TextStyle(
                    color: _color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WheelStatusCard
// ─────────────────────────────────────────────────────────────────────────────
class WheelStatusCard extends StatelessWidget {
  final String position;
  final AlignmentStatus status;
  final double? angle;
  final double? deviation;
  final double? speed;

  const WheelStatusCard({
    super.key,
    required this.position,
    required this.status,
    this.angle,
    this.deviation,
    this.speed,
  });

  Color get _color {
    switch (status) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                position,
                style: TextStyle(
                  color: _color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (angle != null) _row('Angle', '${angle!.toStringAsFixed(2)}°'),
          if (deviation != null) _row('Dev', '${deviation!.toStringAsFixed(2)}°'),
          if (speed != null) _row('Speed', '${speed!.toStringAsFixed(1)} km/h'),
          const SizedBox(height: 6),
          StatusBadge(status: status, fontSize: 10),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SensorValueCard
// ─────────────────────────────────────────────────────────────────────────────
class SensorValueCard extends StatelessWidget {
  final String title;
  final List<SensorRowData> rows;

  const SensorValueCard({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => _SensorRowWidget(row: r)),
        ],
      ),
    );
  }
}

class SensorRowData {
  final String label;
  final String value;
  final Color? valueColor;
  final SensorState? state;

  const SensorRowData(this.label, this.value, {this.valueColor, this.state});
}

class _SensorRowWidget extends StatelessWidget {
  final SensorRowData row;

  const _SensorRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            row.label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            row.value,
            style: TextStyle(
              color: row.valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SensorHealthCard
// ─────────────────────────────────────────────────────────────────────────────
class SensorHealthCard extends StatelessWidget {
  final String name;
  final String position;
  final SensorState state;
  final IconData icon;

  const SensorHealthCard({
    super.key,
    required this.name,
    required this.position,
    required this.state,
    required this.icon,
  });

  Color get _color {
    switch (state) {
      case SensorState.connected: return AppColors.normal;
      case SensorState.warning: return AppColors.warning;
      case SensorState.fault:
      case SensorState.disconnected:
      case SensorState.unavailable: return AppColors.critical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: _color),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            position,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            name,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            state.label,
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AlertCard
// ─────────────────────────────────────────────────────────────────────────────
class AlertCard extends StatelessWidget {
  final dynamic alert; // AlertModel
  final VoidCallback? onAcknowledge;

  const AlertCard({super.key, required this.alert, this.onAcknowledge});

  Color get _severityColor {
    switch (alert.severity.toString()) {
      case 'AlertSeverity.critical': return AppColors.critical;
      case 'AlertSeverity.warning': return AppColors.warning;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.acknowledged
              ? AppColors.cardBorder
              : color.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alert.type.toString().contains('alignment')
                    ? Icons.sync_problem
                    : alert.type.toString().contains('sensor')
                        ? Icons.sensors_off
                        : alert.type.toString().contains('connection')
                            ? Icons.wifi_off
                            : alert.type.toString().contains('calibration')
                                ? Icons.tune
                                : Icons.info_outline,
                size: 16,
                color: alert.acknowledged ? AppColors.textMuted : color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.typeLabel,
                  style: TextStyle(
                    color: alert.acknowledged ? AppColors.textMuted : color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (!alert.acknowledged)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.message,
            style: TextStyle(
              color: alert.acknowledged
                  ? AppColors.textMuted
                  : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(alert.timestamp),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
              if (!alert.acknowledged && onAcknowledge != null)
                GestureDetector(
                  onTap: onAcknowledge,
                  child: Text(
                    'Mark as Read',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
