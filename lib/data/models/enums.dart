import '../../core/constants.dart';

enum AlignmentStatus { normal, warning, critical, unavailable }

enum ConnectionStatus { connected, connecting, disconnected }

enum SensorState { connected, disconnected, unavailable, warning, fault }

enum AlertSeverity { info, warning, critical }

enum AlertType { alignment, sensor, connection, calibration, system }

extension AlignmentStatusExt on AlignmentStatus {
  String get label {
    switch (this) {
      case AlignmentStatus.normal: return AppConstants.statusNormal;
      case AlignmentStatus.warning: return AppConstants.statusWarning;
      case AlignmentStatus.critical: return AppConstants.statusCritical;
      case AlignmentStatus.unavailable: return AppConstants.statusUnavailable;
    }
  }

  String get message {
    switch (this) {
      case AlignmentStatus.normal:
        return 'Alignment condition is within calibrated tolerance.';
      case AlignmentStatus.warning:
        return 'Alignment deviation detected. Inspection may be required.';
      case AlignmentStatus.critical:
        return 'Significant alignment-related deviation detected. Service inspection recommended.';
      case AlignmentStatus.unavailable:
        return 'Alignment data unavailable.';
    }
  }
}

extension SensorStateExt on SensorState {
  String get label {
    switch (this) {
      case SensorState.connected: return 'Connected';
      case SensorState.disconnected: return 'Disconnected';
      case SensorState.unavailable: return 'Unavailable';
      case SensorState.warning: return 'Warning';
      case SensorState.fault: return 'Fault';
    }
  }
}

extension ConnectionStatusExt on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.connected: return 'Connected';
      case ConnectionStatus.connecting: return 'Connecting...';
      case ConnectionStatus.disconnected: return 'Disconnected';
    }
  }
}
