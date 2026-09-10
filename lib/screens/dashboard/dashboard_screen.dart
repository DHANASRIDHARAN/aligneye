import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final reading = provider.latestReading;
        final vehicle = provider.vehicle;
        final unread = provider.unreadAlerts;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                if (provider.isDemoMode) const DemoBanner(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // ── Header ─────────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.appName,
                                    style: GoogleFonts.rajdhani(
                                      color: AppColors.textPrimary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  Text(
                                    vehicle.vehicleName,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ConnectionStatusWidget(
                                    status: provider.connectionStatus,
                                    compact: true,
                                  ),
                                  if (provider.lastSync != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sync: ${DateFormat('HH:mm:ss').format(provider.lastSync!)}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([

                            // ── Overall Status ───────────────────────────────
                            AlignmentStatusCard(
                              status: reading?.overallStatus ??
                                  provider.overallStatus,
                            ),
                            const SizedBox(height: 16),

                            // ── Latest Alert ─────────────────────────────────
                            if (unread.isNotEmpty) ...[
                              AppCard(
                                borderColor: AppColors.warning.withOpacity(0.5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Latest Alert',
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            unread.first.message,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/alerts'),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ── Vehicle Diagram ──────────────────────────────
                            AppCard(
                              child: Column(
                                children: [
                                  const SectionHeader(
                                    title: 'Wheel Status Overview',
                                  ),
                                  const SizedBox(height: 8),
                                  VehicleDiagram(
                                    flStatus: reading?.flStatus ??
                                        provider.overallStatus,
                                    frStatus: reading?.frStatus ??
                                        provider.overallStatus,
                                    rlStatus: reading?.rlStatus ??
                                        provider.overallStatus,
                                    rrStatus: reading?.rrStatus ??
                                        provider.overallStatus,
                                  ),
                                  const SizedBox(height: 12),
                                  // Wheel labels row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: WheelStatusCard(
                                          position: 'FL',
                                          status: reading?.flStatus ??
                                              provider.overallStatus,
                                          angle: reading?.flWheelAngle,
                                          deviation: reading?.flDeviation,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: WheelStatusCard(
                                          position: 'FR',
                                          status: reading?.frStatus ??
                                              provider.overallStatus,
                                          angle: reading?.frWheelAngle,
                                          deviation: reading?.frDeviation,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: WheelStatusCard(
                                          position: 'RL',
                                          status: reading?.rlStatus ??
                                              provider.overallStatus,
                                          angle: reading?.rlWheelAngle,
                                          deviation: reading?.rlDeviation,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: WheelStatusCard(
                                          position: 'RR',
                                          status: reading?.rrStatus ??
                                              provider.overallStatus,
                                          angle: reading?.rrWheelAngle,
                                          deviation: reading?.rrDeviation,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Alignment Overview ───────────────────────────
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(title: 'Alignment Overview'),
                                  const SizedBox(height: 14),
                                  _overviewRow('Front Axle Deviation',
                                      reading?.frontAxleDeviation != null
                                          ? '${reading!.frontAxleDeviation!.toStringAsFixed(2)}°'
                                          : '—'),
                                  _overviewRow('Rear Axle Deviation',
                                      reading?.rearAxleDeviation != null
                                          ? '${reading!.rearAxleDeviation!.toStringAsFixed(2)}°'
                                          : '—'),
                                  _overviewRow('Left-Right Difference',
                                      reading?.lrDifference != null
                                          ? '${reading!.lrDifference!.toStringAsFixed(2)}°'
                                          : '—'),
                                  _overviewRow('Steering Correlation',
                                      reading?.steeringCorrelation != null
                                          ? '${(reading!.steeringCorrelation! * 100).toStringAsFixed(0)}%'
                                          : '—'),
                                  _overviewRow('Confidence',
                                      reading?.confidence != null
                                          ? '${(reading!.confidence! * 100).toStringAsFixed(0)}%'
                                          : '—'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Vehicle Motion ────────────────────────────────
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(title: 'Vehicle Motion'),
                                  const SizedBox(height: 14),
                                  GridView.count(
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.1,
                                    children: [
                                      MetricCard(
                                        label: 'Speed',
                                        value: reading?.vehicleSpeed
                                                ?.toStringAsFixed(1) ??
                                            '—',
                                        unit: 'km/h',
                                        icon: Icons.speed,
                                      ),
                                      MetricCard(
                                        label: 'Steering',
                                        value: reading?.steeringAngle
                                                ?.toStringAsFixed(1) ??
                                            '—',
                                        unit: '°',
                                        icon: Icons.rotate_left,
                                      ),
                                      MetricCard(
                                        label: 'Pitch',
                                        value: reading?.pitch
                                                ?.toStringAsFixed(2) ??
                                            '—',
                                        unit: '°',
                                        icon: Icons.swap_vert,
                                      ),
                                      MetricCard(
                                        label: 'Roll',
                                        value: reading?.roll
                                                ?.toStringAsFixed(2) ??
                                            '—',
                                        unit: '°',
                                        icon: Icons.crop_rotate,
                                      ),
                                      MetricCard(
                                        label: 'Yaw Rate',
                                        value: reading?.yawRate
                                                ?.toStringAsFixed(2) ??
                                            '—',
                                        unit: '°/s',
                                        icon: Icons.restart_alt,
                                      ),
                                      MetricCard(
                                        label: 'Accel Z',
                                        value: reading?.accelZ
                                                ?.toStringAsFixed(2) ??
                                            '—',
                                        unit: 'm/s²',
                                        icon: Icons.arrow_downward,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Quick Actions ─────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _quickAction(
                                    context,
                                    icon: Icons.sensors,
                                    label: 'Live Sensors',
                                    onTap: () => context.go('/sensors'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _quickAction(
                                    context,
                                    icon: Icons.history,
                                    label: 'History',
                                    onTap: () => context.go('/history'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _quickAction(
                                    context,
                                    icon: Icons.notifications_outlined,
                                    label: 'Alerts',
                                    badge: unread.length,
                                    onTap: () => context.go('/alerts'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 90),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _overviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.critical,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
