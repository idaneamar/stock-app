import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/dashboard/dashboard_controller.dart';
import 'package:stock_app/src/features/home/home_controller.dart';
import 'package:stock_app/src/features/home/widgets/scan_filters_dialog_content.dart';
import 'package:stock_app/src/features/stock_list/stock_list_screen.dart';
import 'package:stock_app/src/models/scan_history_response.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        child: Obx(() {
          if (controller.isLoading.value && controller.recentScans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(UIConstants.paddingXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, controller),
                const SizedBox(height: UIConstants.spacingXL),
                _buildPrimaryActionStrip(context),
                const SizedBox(height: UIConstants.spacingXXXL),
                _buildStatCards(controller),
                const SizedBox(height: UIConstants.spacingXXXL),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 560;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildRecentScans(context, controller),
                          const SizedBox(height: UIConstants.spacingXXXL),
                          _buildQuickActions(context, controller),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildRecentScans(context, controller),
                        ),
                        const SizedBox(width: UIConstants.spacingXXXL),
                        Expanded(
                          flex: 2,
                          child: _buildQuickActions(context, controller),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final now = DateTime.now();
    final greeting =
        now.hour < 12
            ? 'Good morning'
            : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: UIConstants.fontL,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: UIConstants.spacingS),
              Text(
                'Stock Dashboard',
                style: TextStyle(
                  fontSize:
                      isMobile ? UIConstants.fontXXL : UIConstants.fontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: controller.fetchDashboardData,
          color: AppColors.grey600,
        ),
      ],
    );
  }

  Widget _buildStatCards(DashboardController controller) {
    return Obx(
      () => LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          final cards = [
            _StatCard(
              label: 'Total Scans',
              value: controller.totalScans.value.toString(),
              icon: Icons.search_rounded,
              color: AppColors.blue,
              bgColor: AppColors.blue50,
            ),
            _StatCard(
              label: 'Active Strategies',
              value:
                  '${controller.activeStrategies.value} / ${controller.totalStrategies.value}',
              icon: Icons.category_rounded,
              color: AppColors.success,
              bgColor: AppColors.green50,
            ),
            _StatCard(
              label: 'Completed Today',
              value: controller.completedToday.value.toString(),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF3E8FF),
            ),
            _StatCard(
              label: 'Running Now',
              value: controller.inProgressScans.value.toString(),
              icon: Icons.sync_rounded,
              color: AppColors.warning,
              bgColor: AppColors.warningLight,
              pulse: controller.inProgressScans.value > 0,
            ),
          ];
          if (isNarrow) {
            return Column(
              children:
                  cards
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: UIConstants.spacingL,
                          ),
                          child: c,
                        ),
                      )
                      .toList(),
            );
          }
          return Row(
            children:
                cards
                    .map(
                      (c) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: UIConstants.spacingL,
                          ),
                          child: c,
                        ),
                      ),
                    )
                    .toList(),
          );
        },
      ),
    );
  }

  Widget _buildRecentScans(
    BuildContext context,
    DashboardController controller,
  ) {
    return _SectionCard(
      title: 'Recent Scans',
      action: TextButton(
        onPressed: () {
          // Navigate to Scans tab via MainContainerController
          try {
            final mc = Get.find<dynamic>(tag: 'main_container');
            mc.changeScreen(1);
          } catch (_) {}
        },
        child: const Text('View all'),
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.recentScans.isEmpty) {
          return _SectionStateMessage(
            icon: Icons.sync_rounded,
            message: 'Loading recent scans...',
          );
        }
        if (controller.recentScans.isEmpty) {
          return const _SectionStateMessage(
            icon: Icons.search_off_rounded,
            message: 'No scans yet',
          );
        }
        return Column(
          children:
              controller.recentScans
                  .map((scan) => _ScanRow(scan: scan))
                  .toList(),
        );
      }),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    DashboardController controller,
  ) {
    return _SectionCard(
      title: 'Quick Actions',
      action: TextButton(
        onPressed: () => _navigateTo(1),
        child: const Text('Go to Scans'),
      ),
      child: Column(
        children: [
          _ActionButton(
            icon: Icons.search_rounded,
            label: 'New Scan',
            subtitle: 'Scan the market for signals',
            color: AppColors.blue,
            onTap: () => _openScanDialog(context),
          ),
          const SizedBox(height: UIConstants.spacingL),
          _ActionButton(
            icon: Icons.layers_rounded,
            label: 'Programs',
            subtitle: 'Manage strategy sets',
            color: const Color(0xFF7C3AED),
            onTap: () => _navigateTo(2),
          ),
          const SizedBox(height: UIConstants.spacingL),
          _ActionButton(
            icon: Icons.category_rounded,
            label: 'Strategies',
            subtitle: 'Configure individual rules',
            color: AppColors.success,
            onTap: () => _navigateTo(3),
          ),
          const SizedBox(height: UIConstants.spacingL),
          _ActionButton(
            icon: Icons.settings_rounded,
            label: 'Engine Settings',
            subtitle: 'Global scan behaviour',
            color: AppColors.grey600,
            onTap: () => _navigateTo(8),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionStrip(BuildContext context) {
    return Wrap(
      spacing: UIConstants.spacingM,
      runSpacing: UIConstants.spacingM,
      children: [
        FilledButton.icon(
          onPressed: () => _openScanDialog(context),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Run New Scan'),
        ),
        OutlinedButton.icon(
          onPressed: () => _navigateTo(2),
          icon: const Icon(Icons.layers_rounded),
          label: const Text('Programs'),
        ),
        OutlinedButton.icon(
          onPressed: () => _navigateTo(8),
          icon: const Icon(Icons.settings_rounded),
          label: const Text('Engine Settings'),
        ),
      ],
    );
  }

  void _navigateTo(int index) {
    try {
      Get.find<dynamic>(tag: 'main_container').changeScreen(index);
    } catch (_) {}
  }

  void _openScanDialog(BuildContext context) {
    try {
      final homeCtrl = Get.find<HomeController>();
      homeCtrl.refreshPrograms();
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Stock Filters'),
              content: ScanFiltersDialogContent(controller: homeCtrl),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await homeCtrl.fetchStocks();
                    // Switch to scans tab so user can see progress
                    _navigateTo(1);
                  },
                  child: const Text('Run Scan'),
                ),
              ],
            ),
      );
    } catch (_) {
      // HomeController not yet initialized — navigate to scans tab first
      _navigateTo(1);
    }
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool pulse;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (pulse)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingXXXL),
          Text(
            value,
            style: const TextStyle(
              fontSize: UIConstants.fontTitle,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontL,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card wrapper
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _SectionCard({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: UIConstants.fontXXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (action != null) ...[const Spacer(), action!],
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          const Divider(height: 1),
          const SizedBox(height: UIConstants.spacingL),
          child,
        ],
      ),
    );
  }
}

class _SectionStateMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SectionStateMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.grey400),
            const SizedBox(height: UIConstants.spacingL),
            Text(message, style: TextStyle(color: AppColors.grey500)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scan row
// ---------------------------------------------------------------------------

class _ScanRow extends StatelessWidget {
  final ScanHistoryData scan;

  const _ScanRow({required this.scan});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(scan.status);
    final statusLabel = _statusLabel(scan.status);

    return InkWell(
      borderRadius: BorderRadius.circular(UIConstants.radiusM),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScanAnalysisScreen(scanId: scan.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingS),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan #${scan.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: UIConstants.fontL,
                    ),
                  ),
                  Text(
                    _formatDate(scan.createdAt),
                    style: TextStyle(
                      fontSize: UIConstants.fontM,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: UIConstants.fontXS,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (scan.totalFound > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${scan.totalFound} stocks',
                    style: TextStyle(
                      fontSize: UIConstants.fontXS,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Done';
      case 'in_progress':
        return 'Running';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ---------------------------------------------------------------------------
// Action button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UIConstants.radiusM),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: UIConstants.fontL,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: UIConstants.fontM,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
