class AppConstants {
  static const appName = 'ALIGNEYE';
  static const appSubtitle = 'Smart Wheel Alignment Monitoring';
  static const appVersion = '1.0.0';
  static const appBuild = '1';

  // Wheel positions
  static const fl = 'FL';
  static const fr = 'FR';
  static const rl = 'RL';
  static const rr = 'RR';

  // Alignment status strings
  static const statusNormal = 'NORMAL';
  static const statusWarning = 'WARNING';
  static const statusCritical = 'CRITICAL';
  static const statusUnavailable = 'UNAVAILABLE';
  static const statusFault = 'FAULT';

  // Connection status
  static const connConnected = 'CONNECTED';
  static const connConnecting = 'CONNECTING';
  static const connDisconnected = 'DISCONNECTED';

  // Sensor types
  static const sensorWheelAngle = 'Wheel Angle';
  static const sensorWheelSpeed = 'Wheel Speed';
  static const sensorSteering = 'Steering Angle';
  static const sensorIMU = 'IMU';
  static const sensorController = 'ESP32 Controller';
  static const sensorWireless = 'Wireless Link';

  // Default tolerances (degrees)
  static const defaultTolerance = 0.5;
  static const warningThreshold = 0.3;

  // Demo mode
  static const isDemoMode = true;
  static const demoLabel = 'DEMO DATA';

  // Safety disclaimer
  static const safetyDisclaimer =
      'ALIGNEYE is designed as an alignment-related monitoring and early-warning system. '
      'It is intended to assist the driver or service technician in identifying conditions '
      'that may warrant inspection. It does not replace professional wheel-alignment '
      'inspection or vehicle servicing.';
}
