import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/common_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('About ALIGNEYE',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App identity
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.rotate_right,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  const Text(
                    AppConstants.appSubtitle,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version ${AppConstants.appVersion} (Build ${AppConstants.appBuild})',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Safety disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Safety Information',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppConstants.safetyDisclaimer,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // System info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Hardware System'),
                  const SizedBox(height: 14),
                  ...[
                    ('Controller', 'ESP32-based Vehicle Control Unit'),
                    ('Wheel Angle Sensors', '4× Wheel Angle Sensor Assemblies'),
                    ('Wheel Speed Sensors', '4× Wheel Speed Sensor Assemblies'),
                    ('Steering Sensor', 'Steering Angle Sensor'),
                    ('IMU', 'MPU6050 or equivalent'),
                    ('Wireless', 'Wi-Fi / WebSocket'),
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(item.$1,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ),
                          Expanded(
                            child: Text(item.$2,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Data Processing'),
                  const SizedBox(height: 14),
                  const Text(
                    'The ESP32 vehicle controller is the primary source of processed sensor '
                    'and alignment information. It performs:\n\n'
                    '• Sensor data filtering and synchronization\n'
                    '• Calibration and reference value application\n'
                    '• Multi-sensor alignment evaluation\n'
                    '• Persistence checking before generating alerts\n\n'
                    'The ALIGNEYE app visualizes the processed results and provides '
                    'monitoring, alert management, and historical analysis.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.6),
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
}
