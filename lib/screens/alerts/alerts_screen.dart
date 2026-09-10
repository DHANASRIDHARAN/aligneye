import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Alignment', 'Sensor', 'Connection', 'Calibration'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final alerts = provider.alerts.where((a) {
          if (_filter == 'All') return true;
          return a.typeLabel == _filter;
        }).toList();

        alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Alerts', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              TextButton(
                onPressed: () => provider.acknowledgeAllAlerts(),
                child: const Text('Mark All Read',
                    style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter chips
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final selected = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: selected
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${alerts.length} alert${alerts.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${alerts.where((a) => !a.acknowledged).length} unread',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: alerts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text('No alerts',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: alerts.length,
                        itemBuilder: (context, i) {
                          final alert = alerts[i];
                          return AlertCard(
                            alert: alert,
                            onAcknowledge: () =>
                                provider.acknowledgeAlert(alert.alertId),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
