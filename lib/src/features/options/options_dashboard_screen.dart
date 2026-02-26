import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/options/options_activity_panel.dart';
import 'package:stock_app/src/features/options/options_ai_panel.dart';
import 'package:stock_app/src/features/options/options_config_panel.dart';
import 'package:stock_app/src/features/options/options_dashboard_controller.dart';
import 'package:stock_app/src/features/options/options_ibkr_log_sheet.dart';
import 'package:stock_app/src/models/options_recommendation.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';

// Colour constants matching the sidebar palette
const Color _accent = Color(0xFF4F78FF);
const Color _accentLight = Color(0xFFEEF2FF);
const Color _cardBg = AppColors.white;
const Color _liveRed = Color(0xFFDC2626);
const Color _paperGreen = Color(0xFF059669);
const Color _testAmber = Color(0xFFF59E0B);

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
          _SystemHealthBar(ctrl: ctrl),
          _ActionBar(ctrl: ctrl),
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

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial =
        ctrl.currentDate.value.isNotEmpty
            ? DateTime.tryParse(ctrl.currentDate.value) ?? now
            : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select recommendations date',
      builder:
          (ctx, child) => Theme(
            data: Theme.of(
              ctx,
            ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
            child: child!,
          ),
    );

    if (picked != null) {
      final dateStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ctrl.fetchRecommendations(date: dateStr);
    }
  }

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
                  return Tooltip(
                    message: 'Tap to load recommendations for a specific date',
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d.isNotEmpty ? 'Date: $d' : 'Loading...',
                              style: const TextStyle(
                                fontSize: UIConstants.fontL,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Config settings icon
          IconButton(
            onPressed: () async {
              await showOptionsConfigPanel(context);
              ctrl.reloadConfig();
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Options Configuration',
            color: AppColors.textSecondary,
          ),
          // System Activity log
          IconButton(
            onPressed: () => showOptionsActivityPanel(context),
            icon: const Icon(Icons.terminal_rounded),
            tooltip: 'System Activity Log',
            color: AppColors.textSecondary,
          ),
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
// System Health Bar — compact strip: ThetaData · IBKR mode · data age · symbols
// ---------------------------------------------------------------------------

class _SystemHealthBar extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _SystemHealthBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ms = ctrl.morningStatus.value;
      final s = ctrl.status.value;
      final cfg = ctrl.config.value;

      final prefetch = ms?['last_prefetch'] as Map<String, dynamic>?;
      final prefetchOk = prefetch?['ok'] == true;
      final prefetchAge = _formatRelative(
        prefetch?['ended_at'] ?? prefetch?['ran_at'],
      );
      final prefetchDate = _formatDate(
        prefetch?['ended_at'] ?? prefetch?['ran_at'],
      );
      final isSyncing = ctrl.prefetchState.value == OptionsLoadState.loading;

      final isDryRun = cfg.dryRun;
      final isLive = !cfg.isPaper;
      final modeColor =
          isDryRun
              ? _testAmber
              : isLive
              ? _liveRed
              : _paperGreen;
      final modeLabel =
          isDryRun
              ? 'TEST'
              : isLive
              ? 'LIVE'
              : 'PAPER';
      final modeIcon =
          isDryRun
              ? Icons.science_outlined
              : isLive
              ? Icons.bolt_rounded
              : Icons.verified_outlined;

      return Container(
        color: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingXXL,
          vertical: 8,
        ),
        child: Row(
          children: [
            // ThetaData status dot
            GestureDetector(
              onTap: () => showOptionsActivityPanel(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: prefetchOk ? _paperGreen : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ThetaData',
                    style: TextStyle(
                      fontSize: UIConstants.fontS,
                      color: prefetchOk ? _paperGreen : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: UIConstants.spacingXL),
            // Data coverage + sync button
            if (prefetch != null) ...[
              Tooltip(
                message:
                    prefetchDate.isNotEmpty
                        ? 'Options data synced on $prefetchDate ($prefetchAge)'
                        : 'Synced $prefetchAge',
                child: Text(
                  'Synced: $prefetchDate',
                  style: const TextStyle(
                    fontSize: UIConstants.fontS,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message:
                    'Sync options data to today\n(downloads latest chains from ThetaData Terminal)',
                child: GestureDetector(
                  onTap: isSyncing ? null : ctrl.triggerPrefetch,
                  child:
                      isSyncing
                          ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          )
                          : const Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                ),
              ),
            ],
            if (s != null) ...[
              const SizedBox(width: UIConstants.spacingXL),
              Text(
                '${s.symbolCount} symbols',
                style: const TextStyle(
                  fontSize: UIConstants.fontS,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
            const Spacer(),
            // IBKR mode badge — tappable to open config
            GestureDetector(
              onTap: () async {
                await showOptionsConfigPanel(context);
                ctrl.reloadConfig();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    UIConstants.radiusCircular,
                  ),
                  border: Border.all(color: modeColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(modeIcon, size: 12, color: modeColor),
                    const SizedBox(width: 5),
                    Text(
                      modeLabel,
                      style: TextStyle(
                        fontSize: UIConstants.fontXS,
                        fontWeight: FontWeight.bold,
                        color: modeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.tune_rounded,
                      size: 11,
                      color: modeColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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

  /// Returns a short human-readable date like "Feb 25" or "Feb 25, 2024".
  String _formatDate(dynamic iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final now = DateTime.now();
      final sameYear = dt.year == now.year;
      final month = months[dt.month - 1];
      return sameYear ? '$month ${dt.day}' : '$month ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ---------------------------------------------------------------------------
// Action Bar — Generate + Prefetch buttons with live status messages
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _ActionBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ms = ctrl.morningStatus.value;
      final isGenerating = ctrl.generateState.value == OptionsLoadState.loading;

      final sp500 = ms?['last_sp500_update'] as Map<String, dynamic>?;
      final running =
          (ms?['running_jobs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      return Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status chips row ─────────────────────────────────────────────
            if (sp500 != null ||
                running.isNotEmpty ||
                ctrl.fetchSymbolsMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.paddingXXL,
                  UIConstants.paddingM,
                  UIConstants.paddingXXL,
                  0,
                ),
                child: Wrap(
                  spacing: UIConstants.spacingM,
                  runSpacing: UIConstants.spacingS,
                  children: [
                    // SP500 pill — tappable to see diff
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
                    // Fetch-symbols status message
                    if (ctrl.fetchSymbolsMessage.value.isNotEmpty)
                      _StatusPill(
                        icon:
                            ctrl.fetchSymbolsState.value ==
                                    OptionsLoadState.loading
                                ? Icons.sync_rounded
                                : Icons.check_circle_outline,
                        label: ctrl.fetchSymbolsMessage.value,
                        color:
                            ctrl.fetchSymbolsState.value ==
                                    OptionsLoadState.error
                                ? AppColors.error
                                : _accent,
                        spinning:
                            ctrl.fetchSymbolsState.value ==
                            OptionsLoadState.loading,
                      ),
                    // Running indicator — tappable to open activity panel
                    if (running.isNotEmpty)
                      _Tappable(
                        onTap: () => showOptionsActivityPanel(context),
                        child: _StatusPill(
                          icon: Icons.sync_rounded,
                          label: '${running.length} running…',
                          color: AppColors.warning,
                          spinning: true,
                          tooltip: 'Tap to see running jobs & cancel',
                        ),
                      ),
                  ],
                ),
              ),
            // ── Buttons row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UIConstants.paddingXXL,
                UIConstants.paddingM,
                UIConstants.paddingXXL,
                UIConstants.paddingM,
              ),
              child: Row(
                children: [
                  // Generate button (2:1 width ratio)
                  Expanded(
                    flex: 2,
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
                              : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        isGenerating
                            ? 'Generating…'
                            : 'Generate Recommendations',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isGenerating
                                ? AppColors.grey300
                                : const Color(0xFF7C3AED),
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isGenerating) ...[
                    const SizedBox(width: UIConstants.spacingS),
                    Tooltip(
                      message: 'Cancel',
                      child: FilledButton(
                        onPressed: ctrl.cancelGenerating,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.all(UIConstants.paddingM),
                          minimumSize: const Size(42, 42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              UIConstants.radiusM,
                            ),
                          ),
                        ),
                        child: const Icon(Icons.stop_rounded, size: 18),
                      ),
                    ),
                  ],
                  const SizedBox(width: UIConstants.spacingS),
                  // Update SP500 list button
                  Obx(() {
                    final isFetching =
                        ctrl.fetchSymbolsState.value ==
                        OptionsLoadState.loading;
                    return Tooltip(
                      message:
                          'Refresh the S&P 500 symbol list from the server.\nRun this periodically to pick up index additions/removals.',
                      child: OutlinedButton(
                        onPressed: isFetching ? null : ctrl.triggerFetchSymbols,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.all(UIConstants.paddingM),
                          minimumSize: const Size(42, 42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              UIConstants.radiusM,
                            ),
                          ),
                        ),
                        child:
                            isFetching
                                ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF6B7280),
                                  ),
                                )
                                : const Icon(
                                  Icons.format_list_bulleted_add,
                                  size: 18,
                                ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // ── Status messages ──────────────────────────────────────────────
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

  String _sp500Label(Map<String, dynamic> s) {
    final at = _formatRelative(s['ran_at']);
    final added = (s['added'] as List?)?.length ?? 0;
    final removed = (s['removed'] as List?)?.length ?? 0;
    final count = s['current_count'];
    if (added == 0 && removed == 0) return 'SP500 · $count symbols · $at';
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

class _Sp500DiffDialog extends StatefulWidget {
  final Map<String, dynamic> sp500;
  const _Sp500DiffDialog({required this.sp500});

  @override
  State<_Sp500DiffDialog> createState() => _Sp500DiffDialogState();
}

class _Sp500DiffDialogState extends State<_Sp500DiffDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _query = '';
  List<String> _allSymbols = [];
  bool _loadingSymbols = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
    _fetchSymbols();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSymbols() async {
    setState(() => _loadingSymbols = true);
    try {
      final data = await OptionsApiService().getSymbols();
      if (mounted) {
        setState(() {
          _allSymbols = data..sort();
          _loadingSymbols = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSymbols = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final added = (widget.sp500['added'] as List?)?.cast<String>() ?? [];
    final removed = (widget.sp500['removed'] as List?)?.cast<String>() ?? [];
    final prevCount = widget.sp500['previous_count'];
    final curCount = widget.sp500['current_count'];
    final ranAt = widget.sp500['ran_at'];
    final ts =
        ranAt != null ? DateTime.tryParse(ranAt.toString())?.toLocal() : null;
    final dateStr =
        ts != null
            ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-'
                '${ts.day.toString().padLeft(2, '0')}  '
                '${ts.hour.toString().padLeft(2, '0')}:'
                '${ts.minute.toString().padLeft(2, '0')}'
            : '';

    final filtered =
        _query.isEmpty
            ? _allSymbols
            : _allSymbols
                .where((s) => s.contains(_query.toUpperCase()))
                .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
      ),
      child: SizedBox(
        width: 480,
        height: 580,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.list_alt_rounded, color: _accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'S&P 500',
                          style: TextStyle(
                            fontSize: UIConstants.fontXXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (dateStr.isNotEmpty)
                          Text(
                            'Updated: $dateStr'
                            '${prevCount != null ? '  ·  $prevCount → $curCount symbols' : ''}',
                            style: const TextStyle(
                              fontSize: UIConstants.fontS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Tab bar
            TabBar(
              controller: _tabs,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Changes'),
                      if (added.isNotEmpty || removed.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${added.length} / -${removed.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('All Symbols'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_allSymbols.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              labelColor: _accent,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: _accent,
            ),
            const Divider(height: 1),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  // Tab 0: Changes
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(UIConstants.paddingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (added.isEmpty && removed.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(
                              top: UIConstants.spacingXXL,
                            ),
                            child: Center(
                              child: Text(
                                'No changes this week\nSame symbols as before.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
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
                            const SizedBox(height: UIConstants.spacingXL),
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
                                        (t) => _TickerChip(
                                          ticker: t,
                                          color: AppColors.error,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  // Tab 1: All Symbols
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search symbol…',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon:
                                _query.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                    : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.radiusM,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_loadingSymbols)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final ticker = filtered[i];
                              final isAdded = added.contains(ticker);
                              final isRemoved = removed.contains(ticker);
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  ticker,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isAdded
                                            ? const Color(0xFF059669)
                                            : isRemoved
                                            ? AppColors.error
                                            : AppColors.textPrimary,
                                  ),
                                ),
                                trailing:
                                    isAdded
                                        ? const Icon(
                                          Icons.add_circle_rounded,
                                          color: Color(0xFF059669),
                                          size: 16,
                                        )
                                        : isRemoved
                                        ? const Icon(
                                          Icons.remove_circle_rounded,
                                          color: AppColors.error,
                                          size: 16,
                                        )
                                        : null,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        _RiskSummaryBar(ctrl: ctrl),
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
                  onAnalyze:
                      () => showOptionsAiPanel(
                        context,
                        recommendations: ctrl.recommendations,
                        recDate: ctrl.currentDate.value,
                        focusedTicker: rec.ticker,
                        portfolioSize: ctrl.config.value.portfolioSize,
                      ),
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
    final cfg = ctrl.config.value;
    final isDryRun = cfg.dryRun;
    final isLive = !cfg.isPaper;
    final modeColor =
        isDryRun
            ? _testAmber
            : isLive
            ? _liveRed
            : _paperGreen;
    final modeLabel =
        isDryRun
            ? 'TEST MODE'
            : isLive
            ? 'LIVE'
            : 'PAPER';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Send ${rec.ticker} to IBKR'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM,
                    vertical: UIConstants.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    border: Border.all(color: modeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    modeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: modeColor,
                      fontSize: UIConstants.fontM,
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXL),
                Text(
                  'Net credit: \$${rec.netCredit?.toStringAsFixed(2) ?? "?"}/share\n'
                  'Contracts: ${rec.contracts ?? "?"}  ·  '
                  'Max risk: \$${rec.maxRiskUsd?.toStringAsFixed(0) ?? "?"}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: modeColor),
                icon: Icon(
                  isDryRun ? Icons.science_outlined : Icons.send_rounded,
                  size: UIConstants.iconM,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await ctrl.executeSingle(rec);
                  if (context.mounted) {
                    showIbkrLogSheet(context, result);
                  }
                },
                label: Text(isDryRun ? 'Test Run' : 'Execute'),
              ),
            ],
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Risk Summary Bar — aggregate stats strip for loaded recommendations
// ---------------------------------------------------------------------------

class _RiskSummaryBar extends StatelessWidget {
  final OptionsDashboardController ctrl;
  const _RiskSummaryBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recs = ctrl.recommendations;
      if (recs.isEmpty) return const SizedBox.shrink();
      final count = recs.length;
      final totalRisk = ctrl.totalMaxRisk;
      final totalCredit = ctrl.totalPotentialCredit;
      final portfolioSize = ctrl.config.value.portfolioSize;
      final portfolioPct =
          portfolioSize > 0 ? (totalRisk / portfolioSize * 100) : 0.0;

      return Container(
        color: const Color(0xFF1F2937),
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingXXL,
          vertical: 8,
        ),
        child: Row(
          children: [
            _RiskStat(label: 'Trades', value: '$count'),
            _RiskDivider(),
            _RiskStat(
              label: 'Max Risk',
              value: '\$${_fmt(totalRisk)}',
              valueColor: const Color(0xFFFCA5A5),
            ),
            _RiskDivider(),
            _RiskStat(
              label: 'Potential Credit',
              value: '\$${_fmt(totalCredit)}',
              valueColor: const Color(0xFF86EFAC),
            ),
            _RiskDivider(),
            _RiskStat(
              label: 'of Portfolio',
              value: '${portfolioPct.toStringAsFixed(1)}%',
              valueColor:
                  portfolioPct > 20
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      );
    });
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _RiskStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _RiskStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: UIConstants.fontM,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }
}

class _RiskDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
    color: const Color(0xFF374151),
  );
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
            final cfg = ctrl.config.value;
            final isDryRun = cfg.dryRun;
            final isLive = !cfg.isPaper;
            final modeColor =
                isDryRun
                    ? _testAmber
                    : isLive
                    ? _liveRed
                    : _paperGreen;
            final modeLabel =
                isDryRun
                    ? 'TEST'
                    : isLive
                    ? 'LIVE'
                    : 'PAPER';
            final btnLabel =
                isDryRun
                    ? 'Test Run All'
                    : isLive
                    ? 'Execute All (Live)'
                    : 'Execute All (Paper)';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Inline IBKR mode badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      UIConstants.radiusCircular,
                    ),
                    border: Border.all(color: modeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    modeLabel,
                    style: TextStyle(
                      fontSize: UIConstants.fontXS,
                      fontWeight: FontWeight.bold,
                      color: modeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingM),
                FilledButton.icon(
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
                          : Icon(
                            isDryRun
                                ? Icons.science_outlined
                                : Icons.send_rounded,
                            size: UIConstants.iconM,
                          ),
                  label: Text(btnLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: modeColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.paddingXL,
                      vertical: UIConstants.paddingM,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(width: UIConstants.spacingL),
          Obx(() {
            final msg = ctrl.executeMessage.value;
            final hasResult = ctrl.lastExecuteResult.value != null;
            if (msg.isEmpty && !hasResult) return const SizedBox.shrink();
            final ok = ctrl.executeState.value == OptionsLoadState.success;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(
                        color: ok ? AppColors.success : AppColors.error,
                        fontSize: UIConstants.fontM,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasResult) ...[
                    const SizedBox(width: UIConstants.spacingM),
                    TextButton.icon(
                      onPressed: () {
                        final result = ctrl.lastExecuteResult.value;
                        if (result != null && context.mounted) {
                          showIbkrLogSheet(context, result);
                        }
                      },
                      icon: const Icon(
                        Icons.terminal_rounded,
                        size: UIConstants.iconXS,
                      ),
                      label: const Text('View Log'),
                      style: TextButton.styleFrom(
                        foregroundColor: _accent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingM,
                          vertical: UIConstants.paddingXS,
                        ),
                      ),
                    ),
                  ],
                ],
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
    final cfg = ctrl.config.value;
    final isDryRun = cfg.dryRun;
    final isLive = !cfg.isPaper;

    final modeColor =
        isDryRun
            ? _testAmber
            : isLive
            ? _liveRed
            : _paperGreen;
    final modeLabel =
        isDryRun
            ? 'TEST MODE'
            : isLive
            ? 'LIVE — Port ${cfg.ibkrPort}'
            : 'PAPER — Port ${cfg.ibkrPort}';
    final modeIcon =
        isDryRun
            ? Icons.science_outlined
            : isLive
            ? Icons.bolt_rounded
            : Icons.verified_outlined;

    final totalRisk = ctrl.totalMaxRisk;
    final totalCredit = ctrl.totalPotentialCredit;
    final portfolioPct =
        cfg.portfolioSize > 0 ? (totalRisk / cfg.portfolioSize * 100) : 0.0;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Execute All to IBKR'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM,
                    vertical: UIConstants.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    border: Border.all(color: modeColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(modeIcon, color: modeColor, size: UIConstants.iconM),
                      const SizedBox(width: UIConstants.spacingM),
                      Text(
                        modeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: modeColor,
                          fontSize: UIConstants.fontL,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXL),
                // Risk summary
                Table(
                  children: [
                    _tableRow('Trades', '$count iron condors'),
                    _tableRow('Max Risk', '\$${totalRisk.toStringAsFixed(0)}'),
                    _tableRow(
                      'Potential Credit',
                      '\$${totalCredit.toStringAsFixed(0)}',
                    ),
                    _tableRow(
                      'Portfolio Risk',
                      '${portfolioPct.toStringAsFixed(1)}%',
                    ),
                    if (!isDryRun) ...[
                      _tableRow(
                        'Stop-Loss',
                        '${(cfg.stopLossPct * 100).round()}% of max loss',
                      ),
                      _tableRow(
                        'Take-Profit',
                        '${(cfg.takeProfitPct * 100).round()}% of credit',
                      ),
                    ],
                  ],
                ),
                if (isDryRun) ...[
                  const SizedBox(height: UIConstants.spacingL),
                  const Text(
                    'Test Mode: no real orders will be submitted to IBKR.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: modeColor),
                icon: Icon(
                  isDryRun ? Icons.science_outlined : Icons.send_rounded,
                  size: UIConstants.iconM,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final result = await ctrl.executeAll();
                  if (context.mounted) {
                    showIbkrLogSheet(context, result);
                  }
                },
                label: Text(isDryRun ? 'Test Run' : 'Execute All'),
              ),
            ],
          ),
    );
  }

  TableRow _tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
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
  final VoidCallback? onDelete;
  final VoidCallback? onAnalyze;
  final bool readOnly;

  const IronCondorCard({
    super.key,
    required this.rec,
    required this.rank,
    this.onExecute,
    this.onDelete,
    this.onAnalyze,
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
                // Breakeven range
                if (rec.shortPut != null && rec.netCredit != null)
                  _Stat(
                    label: 'BE Lower',
                    value:
                        '\$${(rec.shortPut! - rec.netCredit!).toStringAsFixed(2)}',
                    valueColor: AppColors.textSecondary,
                  ),
                if (rec.shortCall != null && rec.netCredit != null)
                  _Stat(
                    label: 'BE Upper',
                    value:
                        '\$${(rec.shortCall! + rec.netCredit!).toStringAsFixed(2)}',
                    valueColor: AppColors.textSecondary,
                  ),
              ],
            ),

            // ── Row 5: action buttons ─────────────────────────────────────
            if (!readOnly) ...[
              const SizedBox(height: UIConstants.spacingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Ask AI button — opens AI panel focused on this ticker
                  if (onAnalyze != null)
                    OutlinedButton.icon(
                      onPressed: onAnalyze,
                      icon: const Icon(
                        Icons.auto_awesome_outlined,
                        size: UIConstants.iconM,
                      ),
                      label: const Text('Ask AI'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                        side: const BorderSide(color: Color(0xFF7C3AED)),
                      ),
                    ),
                  if (onExecute != null) ...[
                    if (onAnalyze != null)
                      const SizedBox(width: UIConstants.spacingM),
                    OutlinedButton.icon(
                      onPressed: onExecute,
                      icon: const Icon(
                        Icons.send_rounded,
                        size: UIConstants.iconM,
                      ),
                      label: const Text('Send to IBKR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        side: const BorderSide(color: _accent),
                      ),
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: UIConstants.spacingM),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: UIConstants.iconM,
                      ),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ],
                ],
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
