import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/enums.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _controllerIdController = TextEditingController();
  bool _editing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final v = context.read<AppProvider>().vehicle;
    _nameController.text = v.vehicleName;
    _regController.text = v.registrationId ?? '';
    _modelController.text = v.vehicleModel;
    _typeController.text = v.vehicleType;
    _controllerIdController.text = v.controllerId ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _controllerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final vehicle = provider.vehicle;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Vehicle', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              TextButton(
                onPressed: () => setState(() => _editing = !_editing),
                child: Text(
                  _editing ? 'Done' : 'Edit',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Vehicle illustration
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface2, AppColors.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.directions_car, size: 72, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        vehicle.vehicleName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        vehicle.vehicleModel,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ConnectionStatusWidget(status: provider.connectionStatus),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status cards
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Alignment',
                        value: provider.overallStatus.label,
                        color: _statusColor(provider.overallStatus),
                        icon: Icons.tune,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoCard(
                        label: 'Last Calibration',
                        value: vehicle.lastCalibration != null
                            ? DateFormat('dd MMM yyyy').format(vehicle.lastCalibration!)
                            : 'Never',
                        icon: Icons.settings_backup_restore,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Last Inspection',
                        value: vehicle.lastInspection != null
                            ? DateFormat('dd MMM yyyy').format(vehicle.lastInspection!)
                            : 'Never',
                        icon: Icons.build_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoCard(
                        label: 'Controller',
                        value: vehicle.controllerId ?? 'Not set',
                        icon: Icons.memory,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Vehicle profile form
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Vehicle Profile'),
                      const SizedBox(height: 16),
                      _formField('Vehicle Name', _nameController, _editing),
                      const SizedBox(height: 12),
                      _formField('Registration / ID', _regController, _editing),
                      const SizedBox(height: 12),
                      _formField('Vehicle Model', _modelController, _editing),
                      const SizedBox(height: 12),
                      _formField('Vehicle Type', _typeController, _editing),
                      const SizedBox(height: 12),
                      _formField('Sensor/Controller ID', _controllerIdController, _editing),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Connect button
                ElevatedButton.icon(
                  onPressed: provider.isConnected
                      ? () => provider.disconnect()
                      : () => provider.connectDemo(),
                  icon: Icon(provider.isConnected
                      ? Icons.link_off
                      : Icons.link, size: 20),
                  label: Text(provider.isConnected
                      ? 'Disconnect Vehicle'
                      : 'Connect Vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isConnected
                        ? AppColors.critical
                        : AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'In production, "Connect Vehicle" will establish a wireless '
                  'link to the ESP32-based vehicle controller.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(AlignmentStatus status) {
    switch (status) {
      case AlignmentStatus.normal: return AppColors.normal;
      case AlignmentStatus.warning: return AppColors.warning;
      case AlignmentStatus.critical: return AppColors.critical;
      case AlignmentStatus.unavailable: return AppColors.textMuted;
    }
  }

  Widget _formField(String label, TextEditingController ctrl, bool enabled) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? AppColors.surface2 : AppColors.surface3,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 18),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
