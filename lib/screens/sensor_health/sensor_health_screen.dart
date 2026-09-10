import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';
import '../../data/models/enums.dart';

class SensorHealthScreen extends StatelessWidget {
  const SensorHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading;

        final sensors = [
          _SensorInfo('FL', 'Wheel Angle', Icons.rotate_right, r?.flAngleSensorState ?? SensorState.disconnected),
          _SensorInfo('FR', 'Wheel Angle', Icons.rotate_right, r?.frAngleSensorState ?? SensorState.disconnected),
          _SensorInfo('RL', 'Wheel Angle', Icons.rotate_right, r?.rlAngleSensorState ?? SensorState.disconnected),
          _SensorInfo('RR', 'Wheel Angle', Icons.rotate_right, r?.rrAngleSensorState ?? SensorState.disconnected),
          _SensorInfo('FL', 'Wheel Speed', Icons.speed, r?.flSpeedSensorState ?? SensorState.disconnected),
          _SensorInfo('FR', 'Wheel Speed', Icons.speed, r?.frSpeedSensorState ?? SensorState.disconnected),
          _SensorInfo('RL', 'Wheel Speed', Icons.speed, r?.rlSpeedSensorState ?? SensorState.disconnected),
          _SensorInfo('RR', 'Wheel Speed', Icons.speed, r?.rrSpeedSensorState ?? SensorState.disconnected),
          _SensorInfo('—', 'Steering Angle', Icons.drive_eta, r?.steeringSensorState ?? SensorState.disconnected),
          _SensorInfo('—', 'IMU (MPU6050)', Icons.compass_calibration, r?.imuState ?? SensorState.disconnected),
          _SensorInfo('—', 'ESP32 Controller', Icons.memory, r?.controllerState ?? SensorState.disconnected),
          _SensorInfo('—', 'Wireless Link', Icons.wifi, r?.wirelessState ?? SensorState.disconnected),
        ];

        final connected = sensors.where((s) => s.state == SensorState.connected).length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Sensor Health', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary bar
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _HealthStat(
                          label: 'Online',
                          value: '$connected',
                          color: AppColors.normal,
                        ),
                      ),
                      Expanded(
                        child: _HealthStat(
                          label: 'Warning',
                          value: '${sensors.where((s) => s.state == SensorState.warning).length}',
                          color: AppColors.warning,
                        ),
                      ),
                      Expanded(
                        child: _HealthStat(
                          label: 'Fault',
                          value: '${sensors.where((s) => s.state == SensorState.fault || s.state == SensorState.disconnected || s.state == SensorState.unavailable).length}',
                          color: AppColors.critical,
                        ),
                      ),
                      Expanded(
                        child: _HealthStat(
                          label: 'Total',
                          value: '${sensors.length}',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Important notice about fault behavior
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A disconnected or implausible sensor is shown as Unavailable/Fault '
                          'and is NOT interpreted as a valid zero measurement.',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const SectionHeader(title: 'Wheel Angle Sensors'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                  children: sensors.take(4).map((s) => SensorHealthCard(
                    name: s.type,
                    position: s.position,
                    state: s.state,
                    icon: s.icon,
                  )).toList(),
                ),
                const SizedBox(height: 16),

                const SectionHeader(title: 'Wheel Speed Sensors'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                  children: sensors.skip(4).take(4).map((s) => SensorHealthCard(
                    name: s.type,
                    position: s.position,
                    state: s.state,
                    icon: s.icon,
                  )).toList(),
                ),
                const SizedBox(height: 16),

                const SectionHeader(title: 'System Sensors'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                  children: sensors.skip(8).map((s) => SensorHealthCard(
                    name: s.type,
                    position: s.position,
                    state: s.state,
                    icon: s.icon,
                  )).toList(),
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

class _SensorInfo {
  final String position;
  final String type;
  final IconData icon;
  final SensorState state;

  const _SensorInfo(this.position, this.type, this.icon, this.state);
}

class _HealthStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HealthStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
