import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/enums.dart';
import '../data/models/sensor_reading.dart';
import '../data/models/models.dart';
import '../data/demo/demo_data.dart';
import '../data/services/aligneye_connector.dart';

class AppProvider extends ChangeNotifier {
  final AlignEyeConnector _connector = AlignEyeConnector();

  // ── State ──────────────────────────────────────────────────────────────────
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  SensorReading? _latestReading;
  VehicleModel _vehicle = DemoData.vehicle;
  CalibrationModel _calibration = DemoData.calibration;
  List<AlertModel> _alerts = List.from(DemoData.alerts);
  List<HistoryEntry> _history = DemoData.generateHistory();
  bool _isDemoMode = true;
  DateTime? _lastSync;

  StreamSubscription<SensorReading>? _readingSub;
  StreamSubscription<ConnectionStatus>? _statusSub;

  // ── Getters ────────────────────────────────────────────────────────────────
  ConnectionStatus get connectionStatus => _connectionStatus;
  SensorReading? get latestReading => _latestReading;
  VehicleModel get vehicle => _vehicle;
  CalibrationModel get calibration => _calibration;
  List<AlertModel> get alerts => _alerts;
  List<AlertModel> get unreadAlerts => _alerts.where((a) => !a.acknowledged).toList();
  List<HistoryEntry> get history => _history;
  bool get isDemoMode => _isDemoMode;
  DateTime? get lastSync => _lastSync;

  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  bool get isConnecting => _connectionStatus == ConnectionStatus.connecting;

  AlignmentStatus get overallStatus =>
      _latestReading?.overallStatus ?? AlignmentStatus.unavailable;

  // ── Initialize (demo mode auto-connect) ────────────────────────────────────
  AppProvider() {
    _statusSub = _connector.connectionStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
    });
    _readingSub = _connector.sensorStream.listen((reading) {
      _latestReading = reading;
      _lastSync = DateTime.now();
      notifyListeners();
    });
    // Auto-connect in demo mode
    connectDemo();
  }

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connectDemo() async {
    _isDemoMode = true;
    _latestReading = DemoData.currentReading;
    _lastSync = DateTime.now();
    notifyListeners();
    await _connector.connect(mode: ConnectorMode.demo);
  }

  Future<void> connectToDevice(String endpoint) async {
    _isDemoMode = false;
    await _connector.connect(endpoint: endpoint, mode: ConnectorMode.websocket);
  }

  void disconnect() {
    _connector.disconnect();
  }

  // ── Alerts ─────────────────────────────────────────────────────────────────
  void acknowledgeAlert(String alertId) {
    final idx = _alerts.indexWhere((a) => a.alertId == alertId);
    if (idx != -1) {
      _alerts[idx].acknowledged = true;
      notifyListeners();
    }
  }

  void acknowledgeAllAlerts() {
    for (final a in _alerts) {
      a.acknowledged = true;
    }
    notifyListeners();
  }

  // ── Vehicle ────────────────────────────────────────────────────────────────
  void updateVehicle(VehicleModel updated) {
    _vehicle = updated;
    notifyListeners();
  }

  // ── Calibration ────────────────────────────────────────────────────────────
  void updateCalibration(CalibrationModel updated) {
    _calibration = updated;
    notifyListeners();
  }

  // ── History ─────────────────────────────────────────────────────────────────
  List<HistoryEntry> getHistoryForRange(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _history.where((h) => h.timestamp.isAfter(cutoff)).toList();
  }

  @override
  void dispose() {
    _readingSub?.cancel();
    _statusSub?.cancel();
    _connector.dispose();
    super.dispose();
  }
}

class SettingsProvider extends ChangeNotifier {
  bool _alignmentWarningNotif = true;
  bool _criticalAlertNotif = true;
  bool _sensorFaultNotif = true;
  bool _disconnectionNotif = true;
  bool _calibrationReminderNotif = true;
  String _units = 'Metric';
  String _angleUnit = 'Degrees';

  bool get alignmentWarningNotif => _alignmentWarningNotif;
  bool get criticalAlertNotif => _criticalAlertNotif;
  bool get sensorFaultNotif => _sensorFaultNotif;
  bool get disconnectionNotif => _disconnectionNotif;
  bool get calibrationReminderNotif => _calibrationReminderNotif;
  String get units => _units;
  String get angleUnit => _angleUnit;

  void setAlignmentWarningNotif(bool v) { _alignmentWarningNotif = v; notifyListeners(); }
  void setCriticalAlertNotif(bool v) { _criticalAlertNotif = v; notifyListeners(); }
  void setSensorFaultNotif(bool v) { _sensorFaultNotif = v; notifyListeners(); }
  void setDisconnectionNotif(bool v) { _disconnectionNotif = v; notifyListeners(); }
  void setCalibrationReminderNotif(bool v) { _calibrationReminderNotif = v; notifyListeners(); }
  void setUnits(String v) { _units = v; notifyListeners(); }
  void setAngleUnit(String v) { _angleUnit = v; notifyListeners(); }
}
