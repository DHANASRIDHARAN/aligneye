import 'enums.dart';

class SensorReading {
  final String vehicleId;
  final DateTime timestamp;

  // Wheel Angle Sensors (degrees)
  final double? flWheelAngle;
  final double? frWheelAngle;
  final double? rlWheelAngle;
  final double? rrWheelAngle;

  // Wheel Speed Sensors (km/h)
  final double? flWheelSpeed;
  final double? frWheelSpeed;
  final double? rlWheelSpeed;
  final double? rrWheelSpeed;

  // Steering Angle Sensor (degrees)
  final double? steeringAngle;
  final double? steeringReference;

  // IMU Data
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? angularRateX;
  final double? angularRateY;
  final double? angularRateZ;
  final double? pitch;
  final double? roll;
  final double? yawRate;

  // Vehicle Speed (derived)
  final double? vehicleSpeed;

  // Alignment Results (processed by ESP32)
  final AlignmentStatus overallStatus;
  final AlignmentStatus flStatus;
  final AlignmentStatus frStatus;
  final AlignmentStatus rlStatus;
  final AlignmentStatus rrStatus;

  // Deviations (degrees)
  final double? flDeviation;
  final double? frDeviation;
  final double? rlDeviation;
  final double? rrDeviation;
  final double? frontAxleDeviation;
  final double? rearAxleDeviation;
  final double? lrDifference;
  final double? steeringCorrelation;
  final double? confidence;

  // Sensor health
  final SensorState flAngleSensorState;
  final SensorState frAngleSensorState;
  final SensorState rlAngleSensorState;
  final SensorState rrAngleSensorState;
  final SensorState flSpeedSensorState;
  final SensorState frSpeedSensorState;
  final SensorState rlSpeedSensorState;
  final SensorState rrSpeedSensorState;
  final SensorState steeringSensorState;
  final SensorState imuState;
  final SensorState controllerState;
  final SensorState wirelessState;

  const SensorReading({
    required this.vehicleId,
    required this.timestamp,
    this.flWheelAngle,
    this.frWheelAngle,
    this.rlWheelAngle,
    this.rrWheelAngle,
    this.flWheelSpeed,
    this.frWheelSpeed,
    this.rlWheelSpeed,
    this.rrWheelSpeed,
    this.steeringAngle,
    this.steeringReference,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.angularRateX,
    this.angularRateY,
    this.angularRateZ,
    this.pitch,
    this.roll,
    this.yawRate,
    this.vehicleSpeed,
    this.overallStatus = AlignmentStatus.normal,
    this.flStatus = AlignmentStatus.normal,
    this.frStatus = AlignmentStatus.normal,
    this.rlStatus = AlignmentStatus.normal,
    this.rrStatus = AlignmentStatus.normal,
    this.flDeviation,
    this.frDeviation,
    this.rlDeviation,
    this.rrDeviation,
    this.frontAxleDeviation,
    this.rearAxleDeviation,
    this.lrDifference,
    this.steeringCorrelation,
    this.confidence,
    this.flAngleSensorState = SensorState.connected,
    this.frAngleSensorState = SensorState.connected,
    this.rlAngleSensorState = SensorState.connected,
    this.rrAngleSensorState = SensorState.connected,
    this.flSpeedSensorState = SensorState.connected,
    this.frSpeedSensorState = SensorState.connected,
    this.rlSpeedSensorState = SensorState.connected,
    this.rrSpeedSensorState = SensorState.connected,
    this.steeringSensorState = SensorState.connected,
    this.imuState = SensorState.connected,
    this.controllerState = SensorState.connected,
    this.wirelessState = SensorState.connected,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    final wheelAngles = json['wheelAngles'] as Map<String, dynamic>? ?? {};
    final wheelSpeeds = json['wheelSpeeds'] as Map<String, dynamic>? ?? {};
    final imu = json['imuData'] as Map<String, dynamic>? ?? {};
    final alignment = json['alignmentStatus'] as Map<String, dynamic>? ?? {};
    final deviations = json['deviations'] as Map<String, dynamic>? ?? {};
    final sensorStatus = json['sensorStatus'] as Map<String, dynamic>? ?? {};

    AlignmentStatus parseStatus(String? s) {
      switch (s?.toLowerCase()) {
        case 'warning': return AlignmentStatus.warning;
        case 'critical': return AlignmentStatus.critical;
        case 'unavailable': return AlignmentStatus.unavailable;
        default: return AlignmentStatus.normal;
      }
    }

    SensorState parseSensorState(String? s) {
      switch (s?.toLowerCase()) {
        case 'disconnected': return SensorState.disconnected;
        case 'unavailable': return SensorState.unavailable;
        case 'warning': return SensorState.warning;
        case 'fault': return SensorState.fault;
        default: return SensorState.connected;
      }
    }

    return SensorReading(
      vehicleId: json['vehicleId'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      flWheelAngle: (wheelAngles['FL'] as num?)?.toDouble(),
      frWheelAngle: (wheelAngles['FR'] as num?)?.toDouble(),
      rlWheelAngle: (wheelAngles['RL'] as num?)?.toDouble(),
      rrWheelAngle: (wheelAngles['RR'] as num?)?.toDouble(),
      flWheelSpeed: (wheelSpeeds['FL'] as num?)?.toDouble(),
      frWheelSpeed: (wheelSpeeds['FR'] as num?)?.toDouble(),
      rlWheelSpeed: (wheelSpeeds['RL'] as num?)?.toDouble(),
      rrWheelSpeed: (wheelSpeeds['RR'] as num?)?.toDouble(),
      steeringAngle: (json['steeringAngle'] as num?)?.toDouble(),
      accelX: (imu['accelX'] as num?)?.toDouble(),
      accelY: (imu['accelY'] as num?)?.toDouble(),
      accelZ: (imu['accelZ'] as num?)?.toDouble(),
      angularRateX: (imu['angularRateX'] as num?)?.toDouble(),
      angularRateY: (imu['angularRateY'] as num?)?.toDouble(),
      angularRateZ: (imu['angularRateZ'] as num?)?.toDouble(),
      pitch: (imu['pitch'] as num?)?.toDouble(),
      roll: (imu['roll'] as num?)?.toDouble(),
      yawRate: (imu['yawRate'] as num?)?.toDouble(),
      overallStatus: parseStatus(alignment['overall'] as String?),
      flStatus: parseStatus((alignment['wheels'] as Map?)?['FL'] as String?),
      frStatus: parseStatus((alignment['wheels'] as Map?)?['FR'] as String?),
      rlStatus: parseStatus((alignment['wheels'] as Map?)?['RL'] as String?),
      rrStatus: parseStatus((alignment['wheels'] as Map?)?['RR'] as String?),
      flDeviation: (deviations['FL'] as num?)?.toDouble(),
      frDeviation: (deviations['FR'] as num?)?.toDouble(),
      rlDeviation: (deviations['RL'] as num?)?.toDouble(),
      rrDeviation: (deviations['RR'] as num?)?.toDouble(),
      flAngleSensorState: parseSensorState(sensorStatus['FL_angle'] as String?),
      frAngleSensorState: parseSensorState(sensorStatus['FR_angle'] as String?),
      rlAngleSensorState: parseSensorState(sensorStatus['RL_angle'] as String?),
      rrAngleSensorState: parseSensorState(sensorStatus['RR_angle'] as String?),
      flSpeedSensorState: parseSensorState(sensorStatus['FL_speed'] as String?),
      frSpeedSensorState: parseSensorState(sensorStatus['FR_speed'] as String?),
      rlSpeedSensorState: parseSensorState(sensorStatus['RL_speed'] as String?),
      rrSpeedSensorState: parseSensorState(sensorStatus['RR_speed'] as String?),
      steeringSensorState: parseSensorState(sensorStatus['steering'] as String?),
      imuState: parseSensorState(sensorStatus['imu'] as String?),
      controllerState: parseSensorState(sensorStatus['controller'] as String?),
      wirelessState: parseSensorState(sensorStatus['wireless'] as String?),
    );
  }
}
