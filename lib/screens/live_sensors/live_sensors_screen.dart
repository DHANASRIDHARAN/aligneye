import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';

class LiveSensorsScreen extends StatefulWidget {
  const LiveSensorsScreen({super.key});

  @override
  State<LiveSensorsScreen> createState() => _LiveSensorsScreenState();
}

class _LiveSensorsScreenState extends State<LiveSensorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final r = provider.latestReading;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              'Live Sensors',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ConnectionStatusWidget(
                  status: provider.connectionStatus,
                  compact: true,
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Wheel\nAngles'),
                Tab(text: 'Wheel\nSpeeds'),
                Tab(text: 'Steering'),
                Tab(text: 'IMU'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (provider.isDemoMode) const DemoBanner(),
              if (!provider.isConnected)
                Container(
                  color: AppColors.critical.withOpacity(0.1),
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Live vehicle data unavailable. Controller disconnected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.critical, fontSize: 11),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _WheelAnglesTab(provider: provider, reading: r),
                    _WheelSpeedsTab(provider: provider, reading: r),
                    _SteeringTab(provider: provider, reading: r),
                    _IMUTab(provider: provider, reading: r),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Wheel Angles Tab ──────────────────────────────────────────────────────────
class _WheelAnglesTab extends StatelessWidget {
  final AppProvider provider;
  final dynamic reading;

  const _WheelAnglesTab({required this.provider, required this.reading});

  @override
  Widget build(BuildContext context) {
    final String Function(double?) fmt = (v) =>
        v != null ? '${v.toStringAsFixed(3)}°' : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _WheelAngleCard(
            position: 'Front Left (FL)',
            angle: fmt(reading?.flWheelAngle),
            deviation: reading?.flDeviation,
            status: reading?.flStatus,
            sensorState: reading?.flAngleSensorState,
          ),
          const SizedBox(height: 12),
          _WheelAngleCard(
            position: 'Front Right (FR)',
            angle: fmt(reading?.frWheelAngle),
            deviation: reading?.frDeviation,
            status: reading?.frStatus,
            sensorState: reading?.frAngleSensorState,
          ),
          const SizedBox(height: 12),
          _WheelAngleCard(
            position: 'Rear Left (RL)',
            angle: fmt(reading?.rlWheelAngle),
            deviation: reading?.rlDeviation,
            status: reading?.rlStatus,
            sensorState: reading?.rlAngleSensorState,
          ),
          const SizedBox(height: 12),
          _WheelAngleCard(
            position: 'Rear Right (RR)',
            angle: fmt(reading?.rrWheelAngle),
            deviation: reading?.rrDeviation,
            status: reading?.rrStatus,
            sensorState: reading?.rrAngleSensorState,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _WheelAngleCard extends StatelessWidget {
  final String position;
  final String angle;
  final double? deviation;
  final dynamic status;
  final dynamic sensorState;

  const _WheelAngleCard({
    required this.position,
    required this.angle,
    this.deviation,
    this.status,
    this.sensorState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  if (sensorState != null)
                    SensorStateBadge(state: sensorState),
                  const SizedBox(width: 8),
                  if (status != null) StatusBadge(status: status),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wheel Angle',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      angle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deviation',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviation != null
                          ? '${deviation!.toStringAsFixed(3)}°'
                          : '—',
                      style: TextStyle(
                        color: deviation != null && deviation! > 0.5
                            ? AppColors.warning
                            : AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (deviation != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (deviation! / 1.0).clamp(0.0, 1.0),
                backgroundColor: AppColors.surface2,
                valueColor: AlwaysStoppedAnimation(
                  deviation! > 0.7
                      ? AppColors.critical
                      : deviation! > 0.5
                          ? AppColors.warning
                          : AppColors.normal,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0°', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                const Text('Tolerance: 0.5°', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                const Text('1.0°', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Wheel Speeds Tab ──────────────────────────────────────────────────────────
class _WheelSpeedsTab extends StatelessWidget {
  final AppProvider provider;
  final dynamic reading;

  const _WheelSpeedsTab({required this.provider, required this.reading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SensorValueCard(
            title: 'Wheel Speed Sensors',
            rows: [
              SensorRowData('Front Left (FL)',
                  reading?.flWheelSpeed != null
                      ? '${reading.flWheelSpeed.toStringAsFixed(1)} km/h'
                      : 'N/A'),
              SensorRowData('Front Right (FR)',
                  reading?.frWheelSpeed != null
                      ? '${reading.frWheelSpeed.toStringAsFixed(1)} km/h'
                      : 'N/A'),
              SensorRowData('Rear Left (RL)',
                  reading?.rlWheelSpeed != null
                      ? '${reading.rlWheelSpeed.toStringAsFixed(1)} km/h'
                      : 'N/A'),
              SensorRowData('Rear Right (RR)',
                  reading?.rrWheelSpeed != null
                      ? '${reading.rrWheelSpeed.toStringAsFixed(1)} km/h'
                      : 'N/A'),
            ],
          ),
          const SizedBox(height: 12),
          SensorValueCard(
            title: 'Sensor Health',
            rows: [
              SensorRowData('FL Speed Sensor', reading?.flSpeedSensorState?.label ?? '—'),
              SensorRowData('FR Speed Sensor', reading?.frSpeedSensorState?.label ?? '—'),
              SensorRowData('RL Speed Sensor', reading?.rlSpeedSensorState?.label ?? '—'),
              SensorRowData('RR Speed Sensor', reading?.rrSpeedSensorState?.label ?? '—'),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Steering Tab ──────────────────────────────────────────────────────────────
class _SteeringTab extends StatelessWidget {
  final AppProvider provider;
  final dynamic reading;

  const _SteeringTab({required this.provider, required this.reading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steering Angle Sensor',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _bigMetric('Steering Angle',
                    reading?.steeringAngle != null
                        ? '${reading!.steeringAngle!.toStringAsFixed(2)}°'
                        : '—'),
                const SizedBox(height: 16),
                _bigMetric('Steering Reference',
                    reading?.steeringReference != null
                        ? '${reading!.steeringReference!.toStringAsFixed(2)}°'
                        : '0.00°'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sensor Status',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (reading?.steeringSensorState != null)
                      SensorStateBadge(state: reading!.steeringSensorState),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _bigMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── IMU Tab ───────────────────────────────────────────────────────────────────
class _IMUTab extends StatelessWidget {
  final AppProvider provider;
  final dynamic reading;

  const _IMUTab({required this.provider, required this.reading});

  @override
  Widget build(BuildContext context) {
    String fmt(double? v, {int dp = 3}) =>
        v != null ? v.toStringAsFixed(dp) : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SensorValueCard(
            title: 'Acceleration (m/s²)',
            rows: [
              SensorRowData('Accel X', fmt(reading?.accelX)),
              SensorRowData('Accel Y', fmt(reading?.accelY)),
              SensorRowData('Accel Z', fmt(reading?.accelZ)),
            ],
          ),
          const SizedBox(height: 12),
          SensorValueCard(
            title: 'Angular Rate (°/s)',
            rows: [
              SensorRowData('Angular Rate X', fmt(reading?.angularRateX)),
              SensorRowData('Angular Rate Y', fmt(reading?.angularRateY)),
              SensorRowData('Angular Rate Z', fmt(reading?.angularRateZ)),
            ],
          ),
          const SizedBox(height: 12),
          SensorValueCard(
            title: 'Orientation',
            rows: [
              SensorRowData('Pitch', '${fmt(reading?.pitch, dp: 2)}°'),
              SensorRowData('Roll', '${fmt(reading?.roll, dp: 2)}°'),
              SensorRowData('Yaw Rate', '${fmt(reading?.yawRate, dp: 2)}°/s'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'IMU Sensor Status',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (reading?.imuState != null)
                  SensorStateBadge(state: reading!.imuState),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
