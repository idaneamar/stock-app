import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/options/options_ai_panel.dart';
import 'package:stock_app/src/features/options/options_dashboard_controller.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

// Colour constants matching the sidebar palette
const Color _accent = Color(0xFF4F78FF);
const Color _accentLight = Color(0xFFEEF2FF);
const Color _cardBg = AppColors.white;

class OptionsDashboardScreen extends StatelessWidget {
  const OptionsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OptionsDashboardController());

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          _Header(ctrl: ctrl),
          _StatusBar(ctrl: ctrl),
          Expanded(child: _Body(ctrl: ctrl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        UIConstants.paddingXXL,
        UIConstants.paddingXXL,
        UIConstants.paddingL,
        UIConstants.paddingL,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingS),
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: _accent,
              size: UIConstants.iconXL,
            ),
          ),
          const SizedBox(width: UIConstants.spacingXL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Iron Condor Recommendations',
                  style: TextStyle(
                    fontSize: UIConstants.fontXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(() {
                  final d = ctrl.currentDate.value;
                  return Text(
                    d.isNotEmpty ? 'Date: $d' : 'Loading...',
                    style: const TextStyle(
                      fontSize: UIConstants.fontL,
                      color: AppColors.textSecondary,
                    ),
                  );
                }),
              ],
            ),
          ),
          // Ask AI
          Obx(() {
            final hasRecs = ctrl.recommendations.isNotEmpty;
            return OutlinedButton.icon(
              onPressed:
                  hasRecs
                      ? () => showOptionsAiPanel(
                        context,
                        recommendations: ctrl.recommendations,
                        recDate: ctrl.currentDate.value,
                      )
                      : null,
              icon: const Icon(
                Icons.psychology_outlined,
                size: UIConstants.iconM,
              ),
              label: const Text('Ask AI'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent),
              ),
            );
          }),
          const SizedBox(width: UIConstants.spacingM),
          // Refresh
          Obx(() {
            final loading = ctrl.loadState.value == OptionsLoadState.loading;
            return IconButton(
              onPressed: loading ? null : ctrl.refresh,
              icon:
                  loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status bar
// ---------------------------------------------------------------------------

class _StatusBar extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _StatusBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = ctrl.status.value;
      if (s == null) return const SizedBox.shrink();

      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(
          UIConstants.paddingXXL,
          0,
          UIConstants.paddingXXL,
          UIConstants.paddingL,
        ),
        child: Wrap(
          spacing: UIConstants.spacingM,
          runSpacing: UIConstants.spacingS,
          children: [
            _Chip(
              icon: Icons.list_alt_rounded,
              label: '${s.symbolCount} symbols',
              color: _accent,
            ),
            if (s.latestRecommendationDate != null)
              _Chip(
                icon: Icons.calendar_today_outlined,
                label: 'Latest: ${s.latestRecommendationDate}',
                color: AppColors.success,
              ),
            if (s.nextFetchSymbols != null)
              _Chip(
                icon: Icons.schedule_rounded,
                label: 'Next update: ${_formatNextRun(s.nextFetchSymbols!)}',
                color: AppColors.warning,
              ),
          ],
        ),
      );
    });
  }

  String _formatNextRun(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = dt.difference(now);
      if (diff.inDays > 0) return 'in ${diff.inDays}d ${diff.inHours % 24}h';
      if (diff.inHours > 0)
        return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
      return 'in ${diff.inMinutes}m';
    } catch (_) {
      return iso;
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: UIConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusCircular),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: UIConstants.iconXS, color: color),
          const SizedBox(width: UIConstants.spacingS),
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontS,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _Body({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = ctrl.loadState.value;

      if (state == OptionsLoadState.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state == OptionsLoadState.error) {
        return _ErrorState(ctrl: ctrl);
      }

      if (ctrl.recommendations.isEmpty) {
        return _EmptyState(ctrl: ctrl);
      }

      return _RecommendationsList(ctrl: ctrl);
    });
  }
}

// ---------------------------------------------------------------------------
// Recommendations list
// ---------------------------------------------------------------------------

class _RecommendationsList extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _RecommendationsList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(UIConstants.paddingXXL),
            itemCount: ctrl.recommendations.length,
            itemBuilder: (context, i) {
              final rec = ctrl.recommendations[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.paddingL),
                child: IronCondorCard(
                  rec: rec,
                  rank: i + 1,
                  onExecute: () => _confirmAndExecute(context, ctrl, rec),
                ),
              );
            },
          ),
        ),
        _ExecuteAllBar(ctrl: ctrl),
      ],
    );
  }

  void _confirmAndExecute(
    BuildContext context,
    OptionsDashboardController ctrl,
    OptionsRecommendation rec,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Send to IBKR'),
            content: Text(
              'Execute iron condor for ${rec.ticker}?\n\n'
              'Net credit: \$${rec.netCredit?.toStringAsFixed(2) ?? "?"} per share\n'
              'Contracts: ${rec.contracts ?? "?"}\n'
              'Max risk: \$${rec.maxRiskUsd?.toStringAsFixed(0) ?? "?"}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _accent),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await ctrl.executeSingle(rec);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? '${rec.ticker} order submitted to IBKR'
                              : 'Failed: ${ctrl.executeMessage.value}',
                        ),
                        backgroundColor:
                            ok ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('Execute'),
              ),
            ],
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Execute All bar
// ---------------------------------------------------------------------------

class _ExecuteAllBar extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _ExecuteAllBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            final loading = ctrl.executeState.value == OptionsLoadState.loading;
            return FilledButton.icon(
              onPressed:
                  loading ? null : () => _confirmExecuteAll(context, ctrl),
              icon:
                  loading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_rounded, size: UIConstants.iconM),
              label: const Text('Execute All'),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingXXL,
                  vertical: UIConstants.paddingM,
                ),
              ),
            );
          }),
          const SizedBox(width: UIConstants.spacingXL),
          Obx(() {
            final msg = ctrl.executeMessage.value;
            if (msg.isEmpty) return const SizedBox.shrink();
            final ok = ctrl.executeState.value == OptionsLoadState.success;
            return Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: ok ? AppColors.success : AppColors.error,
                  fontSize: UIConstants.fontL,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmExecuteAll(
    BuildContext context,
    OptionsDashboardController ctrl,
  ) {
    final count = ctrl.recommendations.length;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Execute All to IBKR'),
            content: Text(
              'Send all $count iron condor recommendations to IBKR?\n\n'
              'Make sure IBKR TWS/Gateway is running on port 7497 (paper) or 7496 (live).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _accent),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await ctrl.executeAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'All orders submitted to IBKR'
                              : 'Execution failed: ${ctrl.executeMessage.value}',
                        ),
                        backgroundColor:
                            ok ? AppColors.success : AppColors.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: const Text('Execute All'),
              ),
            ],
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Iron Condor Card
// ---------------------------------------------------------------------------

class IronCondorCard extends StatelessWidget {
  final OptionsRecommendation rec;
  final int rank;
  final VoidCallback? onExecute;
  final bool readOnly;

  const IronCondorCard({
    super.key,
    required this.rec,
    required this.rank,
    this.onExecute,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final pop = rec.popEst ?? 0;
    final popColor =
        pop >= 0.70
            ? AppColors.success
            : pop >= 0.60
            ? AppColors.warning
            : AppColors.error;

    return Card(
      elevation: 1,
      color: _cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: ticker + badges ────────────────────────────────────
            Row(
              children: [
                _RankBadge(rank: rank),
                const SizedBox(width: UIConstants.spacingL),
                Text(
                  rec.ticker,
                  style: const TextStyle(
                    fontSize: UIConstants.fontXXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (rec.spot != null) ...[
                  const SizedBox(width: UIConstants.spacingM),
                  Text(
                    '\$${rec.spot!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: UIConstants.fontL,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                // POP badge
                _PopBadge(pop: pop, color: popColor),
                const SizedBox(width: UIConstants.spacingM),
                // Score badge
                if (rec.score != null) _ScoreBadge(score: rec.score!),
              ],
            ),

            const SizedBox(height: UIConstants.spacingXL),

            // ── Row 2: expiry + DTE ───────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: UIConstants.iconS,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: UIConstants.spacingS),
                Text(
                  'Expiry: ${rec.exp ?? "?"}',
                  style: const TextStyle(
                    fontSize: UIConstants.fontL,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingXL),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Text(
                    '${rec.dte ?? "?"} DTE',
                    style: const TextStyle(
                      fontSize: UIConstants.fontM,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: UIConstants.spacingXL),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: UIConstants.spacingXL),

            // ── Row 3: Iron condor wing visualisation ─────────────────────
            _WingVisualizer(rec: rec),

            const SizedBox(height: UIConstants.spacingXL),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: UIConstants.spacingXL),

            // ── Row 4: financials ─────────────────────────────────────────
            Wrap(
              spacing: UIConstants.spacingXXL,
              runSpacing: UIConstants.spacingM,
              children: [
                _Stat(
                  label: 'Net Credit',
                  value: '\$${rec.netCredit?.toStringAsFixed(2) ?? "?"}',
                  highlight: true,
                ),
                _Stat(
                  label: 'Max Loss/sh',
                  value: '\$${rec.maxLossPerShare?.toStringAsFixed(2) ?? "?"}',
                ),
                _Stat(
                  label: 'Width',
                  value: rec.width?.toStringAsFixed(0) ?? '?',
                ),
                if (rec.contracts != null)
                  _Stat(label: 'Contracts', value: '${rec.contracts}'),
                if (rec.maxRiskUsd != null)
                  _Stat(
                    label: 'Max Risk',
                    value: '\$${rec.maxRiskUsd!.toStringAsFixed(0)}',
                    valueColor: AppColors.error,
                  ),
                if (rec.maxProfitUsd != null)
                  _Stat(
                    label: 'Max Profit',
                    value: '\$${rec.maxProfitUsd!.toStringAsFixed(0)}',
                    valueColor: AppColors.success,
                  ),
              ],
            ),

            // ── Row 5: execute button (live mode only) ────────────────────
            if (!readOnly && onExecute != null) ...[
              const SizedBox(height: UIConstants.spacingXL),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onExecute,
                  icon: const Icon(Icons.send_rounded, size: UIConstants.iconM),
                  label: const Text('Send to IBKR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: const BorderSide(color: _accent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wing visualizer:  [LP ← SP] ··· spot ··· [SC → LC]
// ---------------------------------------------------------------------------

class _WingVisualizer extends StatelessWidget {
  final OptionsRecommendation rec;
  const _WingVisualizer({required this.rec});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Row(
          children: [
            // Put spread
            Expanded(
              child: _SpreadBox(
                label: 'Put Spread',
                left: rec.longPut,
                right: rec.shortPut,
                arrowLeft: false,
                color: AppColors.blue700,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            // Spot
            Column(
              children: [
                const Text(
                  'SPOT',
                  style: TextStyle(
                    fontSize: UIConstants.fontXS,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rec.spot != null ? '\$${rec.spot!.toStringAsFixed(1)}' : '—',
                  style: const TextStyle(
                    fontSize: UIConstants.fontL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: UIConstants.spacingM),
            // Call spread
            Expanded(
              child: _SpreadBox(
                label: 'Call Spread',
                left: rec.shortCall,
                right: rec.longCall,
                arrowLeft: true,
                color: AppColors.red700,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpreadBox extends StatelessWidget {
  final String label;
  final double? left;
  final double? right;
  final bool arrowLeft;
  final Color color;

  const _SpreadBox({
    required this.label,
    required this.left,
    required this.right,
    required this.arrowLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: UIConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontXS,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _fmt(left),
                style: TextStyle(
                  fontSize: UIConstants.fontL,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  arrowLeft
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  size: UIConstants.iconXS,
                  color: color,
                ),
              ),
              Text(
                _fmt(right),
                style: TextStyle(
                  fontSize: UIConstants.fontL,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double? v) => v != null ? v.toStringAsFixed(0) : '?';
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: UIConstants.fontS,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PopBadge extends StatelessWidget {
  final double pop;
  final Color color;
  const _PopBadge({required this.pop, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        'POP ${(pop * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: UIConstants.fontM,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _accentLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      child: Text(
        'Score ${score.toStringAsFixed(3)}',
        style: const TextStyle(
          fontSize: UIConstants.fontM,
          color: _accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const _Stat({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: UIConstants.fontXS,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? UIConstants.fontXXL : UIConstants.fontXL,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color:
                valueColor ??
                (highlight ? AppColors.success : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _EmptyState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_rounded,
              size: UIConstants.iconHuge,
              color: AppColors.grey400,
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            const Text(
              'No recommendations for today',
              style: TextStyle(
                fontSize: UIConstants.fontXXL,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(() {
              final s = ctrl.status.value;
              if (s?.latestRecommendationDate != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: UIConstants.spacingL),
                  child: Text(
                    'Last available: ${s!.latestRecommendationDate}',
                    style: const TextStyle(
                      fontSize: UIConstants.fontL,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: UIConstants.spacingXXXL),
            FilledButton.icon(
              onPressed: ctrl.triggerRunOptsp,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run Recommendations Now'),
              style: FilledButton.styleFrom(backgroundColor: _accent),
            ),
            const SizedBox(height: UIConstants.spacingL),
            TextButton(onPressed: ctrl.refresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _ErrorState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: UIConstants.iconHuge,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            const Text(
              'Failed to load recommendations',
              style: TextStyle(
                fontSize: UIConstants.fontXXL,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Obx(
              () => Text(
                ctrl.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: UIConstants.fontL,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXXL),
            FilledButton.icon(
              onPressed: ctrl.refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: _accent),
            ),
          ],
        ),
      ),
    );
  }
}
