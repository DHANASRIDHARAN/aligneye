import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/enums.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';

class AlignmentAnalysisScreen extends StatelessWidget {
  const AlignmentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading;
        final cal = provider.calibration;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'Alignment Analysis',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.isDemoMode) const DemoBanner(),
                const SizedBox(height: 12),
                // Overall result
                AlignmentStatusCard(
                  status: r?.overallStatus ?? AlignmentStatus.unavailable,
                ),
                const SizedBox(height: 16),

                // Per-wheel analysis
                const SectionHeader(title: 'Per-Wheel Analysis'),
                const SizedBox(height: 12),
                _WheelAnalysisCard(
                  position: 'Front Left (FL)',
                  currentAngle: r?.flWheelAngle,
                  referenceAngle: cal.flReference,
                  deviation: r?.flDeviation,
                  tolerance: cal.tolerance,
                  status: r?.flStatus ?? AlignmentStatus.unavailable,
                ),
                const SizedBox(height: 10),
                _WheelAnalysisCard(
                  position: 'Front Right (FR)',
                  currentAngle: r?.frWheelAngle,
                  referenceAngle: cal.frReference,
                  deviation: r?.frDeviation,
                  tolerance: cal.tolerance,
                  status: r?.frStatus ?? AlignmentStatus.unavailable,
                ),
                const SizedBox(height: 10),
                _WheelAnalysisCard(
                  position: 'Rear Left (RL)',
                  currentAngle: r?.rlWheelAngle,
                  referenceAngle: cal.rlReference,
                  deviation: r?.rlDeviation,
                  tolerance: cal.tolerance,
                  status: r?.rlStatus ?? AlignmentStatus.unavailable,
                ),
                const SizedBox(height: 10),
                _WheelAnalysisCard(
                  position: 'Rear Right (RR)',
                  currentAngle: r?.rrWheelAngle,
                  referenceAngle: cal.rrReference,
                  deviation: r?.rrDeviation,
                  tolerance: cal.tolerance,
                  status: r?.rrStatus ?? AlignmentStatus.unavailable,
                ),
                const SizedBox(height: 16),

                // Alignment result card
                if (r != null &&
                    r.overallStatus != AlignmentStatus.normal) ...[
                  const SectionHeader(title: 'Alignment Result'),
                  const SizedBox(height: 12),
                  _AlignmentResultCard(reading: r, provider: provider),
                  const SizedBox(height: 16),
                ],

                // Important note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Alignment-related deviation detected. Please inspect the vehicle. '
                          'This app is a monitoring and early-warning system, not a replacement for '
                          'certified workshop wheel-alignment measurement.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WheelAnalysisCard extends StatelessWidget {
  final String position;
  final double? currentAngle;
  final double referenceAngle;
  final double? deviation;
  final double tolerance;
  final AlignmentStatus status;

  const _WheelAnalysisCard({
    required this.position,
    this.currentAngle,
    required this.referenceAngle,
    this.deviation,
    required this.tolerance,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dev = deviation ?? 0.0;
    final ratio = (dev / (tolerance * 2)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                position,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric('Current', currentAngle != null
                  ? '${currentAngle!.toStringAsFixed(3)}°'
                  : '—'),
              const SizedBox(width: 16),
              _Metric('Reference', '${referenceAngle.toStringAsFixed(3)}°'),
              const SizedBox(width: 16),
              _Metric('Deviation',
                  deviation != null
                      ? '${deviation!.toStringAsFixed(3)}°'
                      : '—',
                  color: _statusColor),
              const SizedBox(width: 16),
              _Metric('Tolerance', '±${tolerance.toStringAsFixed(2)}°'),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Tolerance zone
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.normal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Deviation bar
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Within tolerance',
                style: TextStyle(
                  color: AppColors.normal.withOpacity(0.7),
                  fontSize: 9,
                ),
              ),
              Text(
                'Tolerance limit',
                style: TextStyle(
                  color: AppColors.warning.withOpacity(0.7),
                  fontSize: 9,
                ),
              ),
              Text(
                'Out of range',
                style: TextStyle(
                  color: AppColors.critical.withOpacity(0.7),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Metric(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _AlignmentResultCard extends StatelessWidget {
  final dynamic reading;
  final AppProvider provider;

  const _AlignmentResultCard({required this.reading, required this.provider});

  @override
  Widget build(BuildContext context) {
    final status = reading.overallStatus as AlignmentStatus;
    final color = status == AlignmentStatus.critical
        ? AppColors.critical
        : AppColors.warning;

    String affectedWheel = '';
    double? maxDev;
    final devs = {
      'FL': reading.flDeviation,
      'FR': reading.frDeviation,
      'RL': reading.rlDeviation,
      'RR': reading.rrDeviation,
    };
    devs.forEach((wheel, dev) {
      if (dev != null && (maxDev == null || dev > maxDev!)) {
        maxDev = dev;
        affectedWheel = wheel;
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Alignment Result',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _resultRow('Overall Status', status.label),
          if (affectedWheel.isNotEmpty)
            _resultRow('Affected Wheel', affectedWheel),
          if (affectedWheel.contains('F') || affectedWheel.contains('R'))
            _resultRow(
              'Affected Axle',
              affectedWheel.contains('F') ? 'Front Axle' : 'Rear Axle',
            ),
          if (maxDev != null)
            _resultRow('Max Deviation', '${maxDev!.toStringAsFixed(3)}°'),
          _resultRow(
            'Detection Time',
            DateFormat('HH:mm:ss').format(reading.timestamp),
          ),
          const Divider(height: 20),
          Text(
            status == AlignmentStatus.critical
                ? 'Significant alignment-related deviation detected. Service inspection recommended immediately.'
                : 'Alignment-related deviation detected. Inspection may be required. Monitor condition.',
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
