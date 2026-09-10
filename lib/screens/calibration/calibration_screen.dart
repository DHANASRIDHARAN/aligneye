import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../data/models/models.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  bool _calibrating = false;
  double _progress = 0;

  void _startCalibration(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Start Calibration',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Calibration will establish new vehicle-specific reference values '
          'and sensor offsets. Ensure the vehicle is on a level surface with '
          'wheels in straight-ahead position.\n\nProceed?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _runCalibration();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Future<void> _runCalibration() async {
    setState(() { _calibrating = true; _progress = 0; });
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _progress = i / 10);
    }
    if (mounted) setState(() => _calibrating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calibration complete. Reference values updated.'),
          backgroundColor: AppColors.normal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final cal = provider.calibration;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Calibration', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          const Text(
                            'Vehicle Alignment Calibration',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Calibration establishes vehicle-specific reference values and sensor offsets. '
                        'Calibrate with the vehicle on a level surface with wheels in straight-ahead position.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Last calibration: ${DateFormat('dd MMM yyyy, HH:mm').format(cal.calibrationDate)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 13,
                              color: cal.isValid ? AppColors.normal : AppColors.critical),
                          const SizedBox(width: 6),
                          Text(
                            cal.isValid ? 'Calibration Valid' : 'Calibration Required',
                            style: TextStyle(
                              color: cal.isValid ? AppColors.normal : AppColors.critical,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Calibration progress
                if (_calibrating) ...[
                  AppCard(
                    borderColor: AppColors.primary.withOpacity(0.4),
                    child: Column(
                      children: [
                        const Text('Calibrating...',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: AppColors.surface2,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_progress * 100).toInt()}% complete',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Reference values
                const SectionHeader(title: 'Wheel Angle Reference Values'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _calRow('Front Left (FL)', cal.flReference),
                      _calRow('Front Right (FR)', cal.frReference),
                      _calRow('Rear Left (RL)', cal.rlReference),
                      _calRow('Rear Right (RR)', cal.rrReference),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const SectionHeader(title: 'Sensor Offsets'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _calRow('FL Offset', cal.flOffset),
                      _calRow('FR Offset', cal.frOffset),
                      _calRow('RL Offset', cal.rlOffset),
                      _calRow('RR Offset', cal.rrOffset),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const SectionHeader(title: 'Other Parameters'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _calRow('Steering Reference', cal.steeringReference),
                      _calRow('Front Mounting Offset', cal.mountingOffsetFront),
                      _calRow('Rear Mounting Offset', cal.mountingOffsetRear),
                      _calRowLabel('Allowable Tolerance', '±${cal.tolerance.toStringAsFixed(2)}°'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                ElevatedButton.icon(
                  onPressed: _calibrating ? null : () => _startCalibration(context),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start Calibration'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _calibrating ? null : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calibration saved.')),
                          );
                        },
                        child: const Text('Save Calibration'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _calibrating ? null : () => _startCalibration(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                        ),
                        child: const Text('Recalibrate'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _calRow(String label, double value) {
    return _calRowLabel(label, '${value.toStringAsFixed(3)}°');
  }

  Widget _calRowLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
