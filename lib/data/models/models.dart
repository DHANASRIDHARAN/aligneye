import 'enums.dart';

class AlertModel {
  final String alertId;
  final String vehicleId;
  final DateTime timestamp;
  final AlertType type;
  final AlertSeverity severity;
  final String? affectedWheel;
  final String? affectedAxle;
  final String message;
  final double? deviation;
  bool acknowledged;

  AlertModel({
    required this.alertId,
    required this.vehicleId,
    required this.timestamp,
    required this.type,
    required this.severity,
    this.affectedWheel,
    this.affectedAxle,
    required this.message,
    this.deviation,
    this.acknowledged = false,
  });

  String get typeLabel {
    switch (type) {
      case AlertType.alignment: return 'Alignment';
      case AlertType.sensor: return 'Sensor';
      case AlertType.connection: return 'Connection';
      case AlertType.calibration: return 'Calibration';
      case AlertType.system: return 'System';
    }
  }

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.info: return 'Info';
      case AlertSeverity.warning: return 'Warning';
      case AlertSeverity.critical: return 'Critical';
    }
  }
}

class VehicleModel {
  String vehicleId;
  String userId;
  String vehicleName;
  String vehicleModel;
  String vehicleType;
  String? registrationId;
  String? controllerId;
  ConnectionStatus connectionStatus;
  DateTime? lastConnected;
  DateTime? lastCalibration;
  DateTime? lastInspection;

  VehicleModel({
    required this.vehicleId,
    required this.userId,
    required this.vehicleName,
    required this.vehicleModel,
    required this.vehicleType,
    this.registrationId,
    this.controllerId,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.lastConnected,
    this.lastCalibration,
    this.lastInspection,
  });
}

class CalibrationModel {
  final String calibrationId;
  final String vehicleId;
  final double flReference;
  final double frReference;
  final double rlReference;
  final double rrReference;
  final double steeringReference;
  final double flOffset;
  final double frOffset;
  final double rlOffset;
  final double rrOffset;
  final double mountingOffsetFront;
  final double mountingOffsetRear;
  final double tolerance;
  final DateTime calibrationDate;
  bool isValid;

  CalibrationModel({
    required this.calibrationId,
    required this.vehicleId,
    required this.flReference,
    required this.frReference,
    required this.rlReference,
    required this.rrReference,
    required this.steeringReference,
    required this.flOffset,
    required this.frOffset,
    required this.rlOffset,
    required this.rrOffset,
    required this.mountingOffsetFront,
    required this.mountingOffsetRear,
    required this.tolerance,
    required this.calibrationDate,
    this.isValid = true,
  });
}

class HistoryEntry {
  final String entryId;
  final DateTime timestamp;
  final AlignmentStatus overallStatus;
  final String? affectedWheel;
  final String? affectedAxle;
  final double? deviation;
  final double? vehicleSpeed;
  final double? steeringAngle;
  final double? flDeviation;
  final double? frDeviation;
  final double? rlDeviation;
  final double? rrDeviation;

  const HistoryEntry({
    required this.entryId,
    required this.timestamp,
    required this.overallStatus,
    this.affectedWheel,
    this.affectedAxle,
    this.deviation,
    this.vehicleSpeed,
    this.steeringAngle,
    this.flDeviation,
    this.frDeviation,
    this.rlDeviation,
    this.rrDeviation,
  });
}
