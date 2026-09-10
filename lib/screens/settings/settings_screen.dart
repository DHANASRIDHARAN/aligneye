import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../data/models/enums.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, SettingsProvider>(
      builder: (context, provider, settings, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile
                _SettingsSection(
                  title: 'User Profile',
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Account',
                      subtitle: 'demo@aligneye.com',
                      onTap: () {},
                    ),
                  ],
                ),

                _SettingsSection(
                  title: 'Vehicle',
                  children: [
                    _SettingsTile(
                      icon: Icons.directions_car_outlined,
                      title: 'Vehicle Profile',
                      subtitle: provider.vehicle.vehicleName,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.tune,
                      title: 'Calibration',
                      subtitle: 'Manage sensor calibration',
                      onTap: () => context.go('/calibration'),
                    ),
                    _SettingsTile(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Sensor Health',
                      subtitle: 'View all sensor statuses',
                      onTap: () => context.go('/sensor-health'),
                    ),
                  ],
                ),

                _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _SettingsToggle(
                      icon: Icons.warning_amber_outlined,
                      title: 'Alignment Warnings',
                      value: settings.alignmentWarningNotif,
                      onChanged: settings.setAlignmentWarningNotif,
                    ),
                    _SettingsToggle(
                      icon: Icons.error_outline,
                      title: 'Critical Alerts',
                      value: settings.criticalAlertNotif,
                      onChanged: settings.setCriticalAlertNotif,
                    ),
                    _SettingsToggle(
                      icon: Icons.sensors_off,
                      title: 'Sensor Faults',
                      value: settings.sensorFaultNotif,
                      onChanged: settings.setSensorFaultNotif,
                    ),
                    _SettingsToggle(
                      icon: Icons.wifi_off,
                      title: 'Controller Disconnection',
                      value: settings.disconnectionNotif,
                      onChanged: settings.setDisconnectionNotif,
                    ),
                    _SettingsToggle(
                      icon: Icons.access_time,
                      title: 'Calibration Reminders',
                      value: settings.calibrationReminderNotif,
                      onChanged: settings.setCalibrationReminderNotif,
                    ),
                  ],
                ),

                _SettingsSection(
                  title: 'Measurement Units',
                  children: [
                    _SettingsChoice(
                      icon: Icons.straighten,
                      title: 'Unit System',
                      value: settings.units,
                      options: const ['Metric', 'Imperial'],
                      onChanged: settings.setUnits,
                    ),
                    _SettingsChoice(
                      icon: Icons.rotate_right,
                      title: 'Angle Unit',
                      value: settings.angleUnit,
                      options: const ['Degrees', 'Radians'],
                      onChanged: settings.setAngleUnit,
                    ),
                  ],
                ),

                _SettingsSection(
                  title: 'Connection',
                  children: [
                    _SettingsTile(
                      icon: Icons.wifi,
                      title: 'Connection Settings',
                      subtitle: 'ESP32 endpoint configuration',
                      onTap: () => _showConnectionDialog(context),
                    ),
                    _SettingsTile(
                      icon: provider.isConnected ? Icons.link_off : Icons.link,
                      title: provider.isConnected
                          ? 'Disconnect Vehicle'
                          : 'Connect to Vehicle',
                      subtitle: provider.connectionStatus.label,
                      onTap: provider.isConnected
                          ? provider.disconnect
                          : provider.connectDemo,
                    ),
                  ],
                ),

                _SettingsSection(
                  title: 'About',
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About ALIGNEYE',
                      subtitle: 'v${AppConstants.appVersion}',
                      onTap: () => context.go('/about'),
                    ),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Safety Information',
                      onTap: () => context.go('/about'),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConnectionDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'ws://192.168.4.1/ws');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('ESP32 Connection',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the WebSocket endpoint of the ESP32 vehicle controller.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Endpoint URL',
                hintText: 'ws://192.168.4.1/ws',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AppProvider>()
                  .connectToDevice(ctrl.text);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

// ── Settings Widgets ──────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: children
                .expand((w) => [w, const Divider(height: 1, indent: 16)])
                .toList()
              ..removeLast(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11))
          : null,
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _SettingsChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SettingsChoice({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.surface2,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        underline: const SizedBox(),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}
