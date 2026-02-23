import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/options/options_activity_panel.dart';
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
          _MorningBriefing(ctrl: ctrl),
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
          // System Activity log
          IconButton(
            onPressed: () => showOptionsActivityPanel(context),
            icon: const Icon(Icons.terminal_rounded),
            tooltip: 'System Activity Log',
            color: AppColors.textSecondary,
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
      if (diff.inHours > 0) {
        return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
      }
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
// Morning briefing + Generate button
// ---------------------------------------------------------------------------

class _MorningBriefing extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _MorningBriefing({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ms = ctrl.morningStatus.value;
      final genState = ctrl.generateState.value;
      final isGenerating = genState == OptionsLoadState.loading;

      final prefetch = ms?['last_prefetch'] as Map<String, dynamic>?;
      final sp500 = ms?['last_sp500_update'] as Map<String, dynamic>?;
      final lastOptsp = ms?['last_optsp'] as Map<String, dynamic>?;
      final running =
          (ms?['running_jobs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final hasRunning = running.isNotEmpty;

      return Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status pills row ────────────────────────────────────────────
            if (ms != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.paddingXXL,
                  UIConstants.paddingM,
                  UIConstants.paddingXXL,
                  UIConstants.paddingS,
                ),
                child: Wrap(
                  spacing: UIConstants.spacingM,
                  runSpacing: UIConstants.spacingS,
                  children: [
                    // Prefetch pill
                    if (prefetch != null && prefetch.isNotEmpty)
                      _StatusPill(
                        icon:
                            prefetch['ok'] == true
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                        label: _prefetchLabel(prefetch),
                        color:
                            prefetch['ok'] == true
                                ? const Color(0xFF059669)
                                : AppColors.error,
                        tooltip: 'Last prefetch: ${prefetch['summary'] ?? ''}',
                      ),
                    // SP500 pill — tappable
                    if (sp500 != null && sp500.isNotEmpty)
                      _Tappable(
                        onTap: () => _showSp500Dialog(context, sp500),
                        child: _StatusPill(
                          icon:
                              sp500['ok'] == true
                                  ? Icons.list_alt_rounded
                                  : Icons.error_outline,
                          label: _sp500Label(sp500),
                          color:
                              sp500['ok'] == true ? _accent : AppColors.error,
                          tooltip: 'Tap to see added / removed symbols',
                          trailing: const Icon(
                            Icons.open_in_new,
                            size: 11,
                            color: _accent,
                          ),
                        ),
                      ),
                    // Running indicator
                    if (hasRunning)
                      _StatusPill(
                        icon: Icons.sync_rounded,
                        label: '${running.length} running…',
                        color: AppColors.warning,
                        spinning: true,
                      ),
                  ],
                ),
              ),
            const Divider(height: 1),
            // ── Generate button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UIConstants.paddingXXL,
                UIConstants.paddingL,
                UIConstants.paddingXXL,
                UIConstants.paddingL,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          isGenerating ? null : ctrl.generateRecommendations,
                      icon:
                          isGenerating
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                              : const Icon(Icons.bolt_rounded, size: 20),
                      label: Text(
                        isGenerating
                            ? 'Generating recommendations…'
                            : 'Generate Today\'s Recommendations',
                        style: const TextStyle(
                          fontSize: UIConstants.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isGenerating
                                ? AppColors.grey300
                                : const Color(0xFF7C3AED),
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Last optsp indicator
                  if (lastOptsp != null && lastOptsp.isNotEmpty) ...[
                    const SizedBox(width: UIConstants.spacingM),
                    Tooltip(
                      message:
                          'Last run: ${_formatRelative(lastOptsp['ran_at'])}',
                      child: Icon(
                        lastOptsp['ok'] == true
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        color:
                            lastOptsp['ok'] == true
                                ? const Color(0xFF059669)
                                : AppColors.warning,
                        size: 22,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Generate status/progress message
            Obx(() {
              final msg = ctrl.generateMessage.value;
              if (msg.isEmpty) return const SizedBox.shrink();
              final isErr = ctrl.generateState.value == OptionsLoadState.error;
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.paddingXXL,
                  0,
                  UIConstants.paddingXXL,
                  UIConstants.paddingM,
                ),
                child: Text(
                  msg,
                  style: TextStyle(
                    fontSize: UIConstants.fontS,
                    color: isErr ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              );
            }),
            const Divider(height: 1),
          ],
        ),
      );
    });
  }

  String _prefetchLabel(Map<String, dynamic> p) {
    final at = _formatRelative(p['ended_at'] ?? p['ran_at']);
    if (p['ok'] == true) return 'Prefetch OK · $at';
    return 'Prefetch failed · $at';
  }

  String _sp500Label(Map<String, dynamic> s) {
    final at = _formatRelative(s['ran_at']);
    final added = (s['added'] as List?)?.length ?? 0;
    final removed = (s['removed'] as List?)?.length ?? 0;
    final count = s['current_count'];
    if (added == 0 && removed == 0) {
      return 'SP500 · $count symbols · $at';
    }
    final parts = <String>[];
    if (added > 0) parts.add('+$added');
    if (removed > 0) parts.add('-$removed');
    return 'SP500 ${parts.join(' ')} · $at';
  }

  String _formatRelative(dynamic iso) {
    if (iso == null) return '?';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return 'just now';
    } catch (_) {
      return iso.toString();
    }
  }

  void _showSp500Dialog(BuildContext context, Map<String, dynamic> sp500) {
    showDialog<void>(
      context: context,
      builder: (_) => _Sp500DiffDialog(sp500: sp500),
    );
  }
}

// ---------------------------------------------------------------------------
// SP500 diff dialog
// ---------------------------------------------------------------------------

class _Sp500DiffDialog extends StatelessWidget {
  final Map<String, dynamic> sp500;
  const _Sp500DiffDialog({required this.sp500});

  @override
  Widget build(BuildContext context) {
    final added = (sp500['added'] as List?)?.cast<String>() ?? [];
    final removed = (sp500['removed'] as List?)?.cast<String>() ?? [];
    final prevCount = sp500['previous_count'];
    final curCount = sp500['current_count'];
    final ranAt = sp500['ran_at'];
    final ts =
        ranAt != null ? DateTime.tryParse(ranAt.toString())?.toLocal() : null;
    final dateStr =
        ts != null
            ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}  ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
            : '';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.list_alt_rounded, color: _accent),
          SizedBox(width: 8),
          Text('S&P 500 Update'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateStr.isNotEmpty)
              Text(
                'Updated: $dateStr',
                style: TextStyle(
                  fontSize: UIConstants.fontS,
                  color: AppColors.textSecondary,
                ),
              ),
            if (prevCount != null && curCount != null) ...[
              const SizedBox(height: 4),
              Text(
                '$prevCount → $curCount symbols',
                style: const TextStyle(
                  fontSize: UIConstants.fontL,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: UIConstants.spacingL),
            if (added.isEmpty && removed.isEmpty)
              const Text('No changes — same symbols as last week.')
            else ...[
              if (added.isNotEmpty) ...[
                _SectionLabel(
                  icon: Icons.add_circle_rounded,
                  label: 'Added (${added.length})',
                  color: const Color(0xFF059669),
                ),
                const SizedBox(height: UIConstants.spacingM),
                Wrap(
                  spacing: UIConstants.spacingS,
                  runSpacing: UIConstants.spacingS,
                  children:
                      added
                          .map(
                            (t) => _TickerChip(
                              ticker: t,
                              color: const Color(0xFF059669),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: UIConstants.spacingL),
              ],
              if (removed.isNotEmpty) ...[
                _SectionLabel(
                  icon: Icons.remove_circle_rounded,
                  label: 'Removed (${removed.length})',
                  color: AppColors.error,
                ),
                const SizedBox(height: UIConstants.spacingM),
                Wrap(
                  spacing: UIConstants.spacingS,
                  runSpacing: UIConstants.spacingS,
                  children:
                      removed
                          .map(
                            (t) =>
                                _TickerChip(ticker: t, color: AppColors.error),
                          )
                          .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: UIConstants.fontL,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TickerChip extends StatelessWidget {
  final String ticker;
  final Color color;
  const _TickerChip({required this.ticker, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        ticker,
        style: TextStyle(
          fontSize: UIConstants.fontS,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// Small helper for tappable wrappers
class _Tappable extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Tappable({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: onTap, child: child);
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;
  final bool spinning;
  final Widget? trailing;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
    this.spinning = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinning
              ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: color,
                ),
              )
              : Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: UIConstants.fontS,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
    if (tooltip != null) {
      pill = Tooltip(message: tooltip!, child: pill);
    }
    return pill;
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

      if (state == OptionsLoadState.offline) {
        return _OfflineState(ctrl: ctrl);
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
              onPressed: ctrl.generateRecommendations,
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
// Offline state — local options server not running
// ---------------------------------------------------------------------------

class _OfflineState extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _OfflineState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.paddingXXL),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.power_off_rounded,
                size: UIConstants.iconHuge,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            const Text(
              'Options server not running',
              style: TextStyle(
                fontSize: UIConstants.fontXXL,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Obx(
              () => Text(
                'Connecting to: ${ctrl.serverUrl.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: UIConstants.fontL,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            Container(
              padding: const EdgeInsets.all(UIConstants.paddingXL),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '# Start the options server on your Mac:',
                    style: TextStyle(color: Color(0xFF6272A4), fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'cd /Volumes/Extreme\\ Pro/App\\ gpt/stock_api-main_updated',
                    style: TextStyle(
                      color: Color(0xFF50FA7B),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'python run_options_server.py --run-now',
                    style: TextStyle(
                      color: Color(0xFF50FA7B),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '# --run-now triggers today\'s jobs immediately',
                    style: TextStyle(color: Color(0xFF6272A4), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: ctrl.refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
