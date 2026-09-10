// ─────────────────────────────────────────────────────────────────────────────
// DEMO DATA — Clearly labeled sample data for prototype/development use.
// Replace with real ESP32 WebSocket data in production.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/enums.dart';
import '../models/sensor_reading.dart';
import '../models/models.dart';

class DemoData {
  static final vehicle = VehicleModel(
    vehicleId: 'VEH-001',
    userId: 'USER-001',
    vehicleName: 'My Vehicle',
    vehicleModel: 'Toyota Camry 2022',
    vehicleType: 'Sedan',
    registrationId: 'TN 01 AB 1234',
    controllerId: 'AE-ESP32-001',
    connectionStatus: ConnectionStatus.connected,
    lastConnected: DateTime.now().subtract(const Duration(minutes: 2)),
    lastCalibration: DateTime.now().subtract(const Duration(days: 14)),
    lastInspection: DateTime.now().subtract(const Duration(days: 60)),
  );

  static final calibration = CalibrationModel(
    calibrationId: 'CAL-001',
    vehicleId: 'VEH-001',
    flReference: 0.0,
    frReference: 0.0,
    rlReference: 0.0,
    rrReference: 0.0,
    steeringReference: 0.0,
    flOffset: 0.05,
    frOffset: 0.03,
    rlOffset: 0.02,
    rrOffset: 0.04,
    mountingOffsetFront: 0.0,
    mountingOffsetRear: 0.0,
    tolerance: 0.5,
    calibrationDate: DateTime.now().subtract(const Duration(days: 14)),
    isValid: true,
  );

  // ── Primary demo reading — FR wheel in WARNING state ──────────────────────
  static SensorReading get currentReading => SensorReading(
    vehicleId: 'VEH-001',
    timestamp: DateTime.now(),
    flWheelAngle: 0.08,
    frWheelAngle: 0.67,    // <-- exceeds tolerance → WARNING
    rlWheelAngle: 0.12,
    rrWheelAngle: 0.09,
    flWheelSpeed: 48.2,
    frWheelSpeed: 48.5,
    rlWheelSpeed: 47.9,
    rrWheelSpeed: 48.1,
    steeringAngle: 1.2,
    steeringReference: 0.0,
    accelX: 0.12,
    accelY: -0.05,
    accelZ: 9.81,
    angularRateX: 0.003,
    angularRateY: -0.001,
    angularRateZ: 0.008,
    pitch: 0.2,
    roll: 0.1,
    yawRate: 0.5,
    vehicleSpeed: 48.2,
    overallStatus: AlignmentStatus.warning,
    flStatus: AlignmentStatus.normal,
    frStatus: AlignmentStatus.warning,
    rlStatus: AlignmentStatus.normal,
    rrStatus: AlignmentStatus.normal,
    flDeviation: 0.08,
    frDeviation: 0.67,
    rlDeviation: 0.12,
    rrDeviation: 0.09,
    frontAxleDeviation: 0.38,
    rearAxleDeviation: 0.11,
    lrDifference: 0.59,
    steeringCorrelation: 0.92,
    confidence: 0.88,
    flAngleSensorState: SensorState.connected,
    frAngleSensorState: SensorState.connected,
    rlAngleSensorState: SensorState.connected,
    rrAngleSensorState: SensorState.connected,
    flSpeedSensorState: SensorState.connected,
    frSpeedSensorState: SensorState.connected,
    rlSpeedSensorState: SensorState.connected,
    rrSpeedSensorState: SensorState.connected,
    steeringSensorState: SensorState.connected,
    imuState: SensorState.connected,
    controllerState: SensorState.connected,
    wirelessState: SensorState.connected,
  );

  static final List<AlertModel> alerts = [
    AlertModel(
      alertId: 'ALT-001',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      type: AlertType.alignment,
      severity: AlertSeverity.warning,
      affectedWheel: 'FR',
      affectedAxle: 'Front',
      message: 'Front Right wheel deviation detected. Alignment-related deviation exceeded configured tolerance.',
      deviation: 0.67,
      acknowledged: false,
    ),
    AlertModel(
      alertId: 'ALT-002',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: AlertType.calibration,
      severity: AlertSeverity.info,
      message: 'Calibration is 14 days old. Consider recalibrating for optimal accuracy.',
      acknowledged: false,
    ),
    AlertModel(
      alertId: 'ALT-003',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: AlertType.alignment,
      severity: AlertSeverity.warning,
      affectedWheel: 'FR',
      affectedAxle: 'Front',
      message: 'Front Right deviation exceeded tolerance.',
      deviation: 0.58,
      acknowledged: true,
    ),
    AlertModel(
      alertId: 'ALT-004',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: AlertType.connection,
      severity: AlertSeverity.info,
      message: 'Vehicle controller disconnected. Live vehicle data unavailable.',
      acknowledged: true,
    ),
    AlertModel(
      alertId: 'ALT-005',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: AlertType.sensor,
      severity: AlertSeverity.warning,
      affectedWheel: 'RL',
      message: 'Rear Left wheel-angle sensor data quality issue detected.',
      acknowledged: true,
    ),
    AlertModel(
      alertId: 'ALT-006',
      vehicleId: 'VEH-001',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      type: AlertType.alignment,
      severity: AlertSeverity.critical,
      affectedWheel: 'RR',
      affectedAxle: 'Rear',
      message: 'Rear Right wheel deviation exceeded critical threshold. Service inspection recommended.',
      deviation: 1.23,
      acknowledged: true,
    ),
  ];

  static List<HistoryEntry> generateHistory() {
    final now = DateTime.now();
    final random = [0.08, 0.12, 0.67, 0.45, 0.31, 0.78, 0.22, 0.55, 0.18, 0.09,
                    0.43, 0.61, 0.88, 0.14, 0.27, 0.52, 0.36, 0.71, 0.19, 0.42,
                    0.05, 0.33, 0.58, 0.24, 0.47, 0.82, 0.15, 0.63, 0.29, 0.11];
    return List.generate(30, (i) {
      final dev = random[i % random.length];
      final status = dev > 0.7
          ? AlignmentStatus.critical
          : dev > 0.45
              ? AlignmentStatus.warning
              : AlignmentStatus.normal;
      return HistoryEntry(
        entryId: 'HIS-${i.toString().padLeft(3, '0')}',
        timestamp: now.subtract(Duration(hours: i * 8)),
        overallStatus: status,
        affectedWheel: dev > 0.45 ? 'FR' : null,
        affectedAxle: dev > 0.45 ? 'Front' : null,
        deviation: dev,
        vehicleSpeed: 30 + (i % 5) * 10.0,
        steeringAngle: (i % 3) * 0.4,
        flDeviation: 0.05 + (i % 4) * 0.02,
        frDeviation: dev,
        rlDeviation: 0.08 + (i % 3) * 0.03,
        rrDeviation: 0.06 + (i % 5) * 0.02,
      );
    });
  }
}
