// ─────────────────────────────────────────────────────────────────────────────
// AlignEyeConnector — ESP32 Integration Layer
//
// This service is the integration point between the ALIGNEYE app and the
// ESP32-based vehicle controller. In production, replace the demo simulation
// with a real WebSocket connection to the ESP32.
//
// Expected ESP32 JSON payload schema:
// {
//   "vehicleId": "...",
//   "timestamp": "ISO8601",
//   "wheelAngles": { "FL": 0.0, "FR": 0.0, "RL": 0.0, "RR": 0.0 },
//   "wheelSpeeds": { "FL": 0.0, "FR": 0.0, "RL": 0.0, "RR": 0.0 },
//   "steeringAngle": 0.0,
//   "imuData": { "accelX":0, "accelY":0, "accelZ":9.81, ... },
//   "alignmentStatus": { "overall": "normal", "wheels": { "FL":"normal", ... } },
//   "deviations": { "FL": 0.0, "FR": 0.0, "RL": 0.0, "RR": 0.0 },
//   "sensorStatus": { "FL_angle":"connected", ... }
// }
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import '../models/enums.dart';
import '../models/sensor_reading.dart';

enum ConnectorMode { demo, websocket, http }

class AlignEyeConnector {
  ConnectorMode _mode = ConnectorMode.demo;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _endpoint;

  final _readingController = StreamController<SensorReading>.broadcast();
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  Timer? _demoTimer;

  Stream<SensorReading> get sensorStream => _readingController.stream;
  Stream<ConnectionStatus> get connectionStream => _statusController.stream;
  ConnectionStatus get currentStatus => _status;

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connect({
    String? endpoint,
    ConnectorMode mode = ConnectorMode.demo,
  }) async {
    _mode = mode;
    _endpoint = endpoint;
    _setStatus(ConnectionStatus.connecting);

    await Future.delayed(const Duration(seconds: 2)); // Simulate handshake

    if (_mode == ConnectorMode.demo) {
      _setStatus(ConnectionStatus.connected);
      _startDemoSimulation();
    } else if (_mode == ConnectorMode.websocket && endpoint != null) {
      await _connectWebSocket(endpoint);
    }
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────
  void disconnect() {
    _demoTimer?.cancel();
    _demoTimer = null;
    _setStatus(ConnectionStatus.disconnected);
  }

  // ── Demo Simulation ────────────────────────────────────────────────────────
  // Simulates periodic sensor updates from an ESP32 controller.
  // In production: remove this and use _connectWebSocket instead.
  void _startDemoSimulation() {
    int tick = 0;
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      tick++;
      final reading = _generateDemoReading(tick);
      _readingController.add(reading);
    });
  }

  SensorReading _generateDemoReading(int tick) {
    // Simulate slight sensor variation around the warning scenario
    final noise = (tick % 7 - 3) * 0.015;
    final frDev = 0.67 + noise;
    final frStatus = frDev > 0.5 ? AlignmentStatus.warning : AlignmentStatus.normal;
    final overall = frStatus == AlignmentStatus.warning
        ? AlignmentStatus.warning
        : AlignmentStatus.normal;

    return SensorReading(
      vehicleId: 'VEH-001',
      timestamp: DateTime.now(),
      flWheelAngle: 0.08 + noise * 0.2,
      frWheelAngle: frDev,
      rlWheelAngle: 0.12 + noise * 0.1,
      rrWheelAngle: 0.09 + noise * 0.15,
      flWheelSpeed: 48.2 + noise * 0.5,
      frWheelSpeed: 48.5 + noise * 0.5,
      rlWheelSpeed: 47.9 + noise * 0.5,
      rrWheelSpeed: 48.1 + noise * 0.5,
      steeringAngle: 1.2 + noise * 0.3,
      steeringReference: 0.0,
      accelX: 0.12 + noise * 0.05,
      accelY: -0.05 + noise * 0.02,
      accelZ: 9.81,
      angularRateX: 0.003 + noise * 0.001,
      angularRateY: -0.001,
      angularRateZ: 0.008 + noise * 0.002,
      pitch: 0.2 + noise * 0.05,
      roll: 0.1 + noise * 0.03,
      yawRate: 0.5 + noise * 0.1,
      vehicleSpeed: 48.2 + noise * 0.5,
      overallStatus: overall,
      flStatus: AlignmentStatus.normal,
      frStatus: frStatus,
      rlStatus: AlignmentStatus.normal,
      rrStatus: AlignmentStatus.normal,
      flDeviation: (0.08 + noise * 0.2).abs(),
      frDeviation: frDev.abs(),
      rlDeviation: (0.12 + noise * 0.1).abs(),
      rrDeviation: (0.09 + noise * 0.15).abs(),
      frontAxleDeviation: (frDev + 0.08).abs() / 2,
      rearAxleDeviation: 0.11,
      lrDifference: (frDev - 0.08).abs(),
      steeringCorrelation: 0.92,
      confidence: 0.88,
    );
  }

  // ── WebSocket Connection (Production) ─────────────────────────────────────
  // Replace with actual WebSocket implementation for ESP32 integration.
  Future<void> _connectWebSocket(String endpoint) async {
    // TODO: Implement WebSocket connection to ESP32
    // Example: ws://192.168.4.1/ws (ESP32 in AP mode)
    //
    // import 'package:web_socket_channel/web_socket_channel.dart';
    // final channel = WebSocketChannel.connect(Uri.parse(endpoint));
    // channel.stream.listen(
    //   (data) => _handlePayload(data),
    //   onError: (e) => _setStatus(ConnectionStatus.disconnected),
    //   onDone: () => _setStatus(ConnectionStatus.disconnected),
    // );
    // _setStatus(ConnectionStatus.connected);
    _setStatus(ConnectionStatus.disconnected);
  }

  void _handlePayload(dynamic raw) {
    try {
      final data = raw is String ? jsonDecode(raw) : raw;
      final reading = SensorReading.fromJson(data as Map<String, dynamic>);
      _readingController.add(reading);
    } catch (e) {
      // Log parse error — do not emit invalid readings
    }
  }

  void _setStatus(ConnectionStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void dispose() {
    _demoTimer?.cancel();
    _readingController.close();
    _statusController.close();
  }
}
