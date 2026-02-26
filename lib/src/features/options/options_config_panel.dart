import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/services/shared_prefs_service.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';

const Color _accent = Color(0xFF4F78FF);
const Color _accentLight = Color(0xFFEEF2FF);
const Color _liveRed = Color(0xFFDC2626);
const Color _paperGreen = Color(0xFF059669);

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> showOptionsConfigPanel(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OptionsConfigSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

class _OptionsConfigSheet extends StatefulWidget {
  const _OptionsConfigSheet();

  @override
  State<_OptionsConfigSheet> createState() => _OptionsConfigSheetState();
}

class _OptionsConfigSheetState extends State<_OptionsConfigSheet>
    with SingleTickerProviderStateMixin {
  // Config state
  int _ibkrPort = 7497;
  int _ibkrClientId = 1;
  bool _dryRun = false;
  double _stopLossPct = 1.0;
  double _takeProfitPct = 0.5;
  double _portfolioSize = 250000.0;
  List<int> _prefetchYears = [DateTime.now().year];
  int _maxTrades = 10;

  bool _loading = true;
  bool _saving = false;

  late final TextEditingController _clientIdCtrl;
  late final TextEditingController _portfolioCtrl;

  // Available years for prefetch multi-select
  late final List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().year;
    _availableYears = [now - 2, now - 1, now];
    _clientIdCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final port = await SharedPrefsService.getOptionsIbkrPort();
    final cid = await SharedPrefsService.getOptionsIbkrClientId();
    final dry = await SharedPrefsService.getOptionsDryRun();
    final sl = await SharedPrefsService.getOptionsStopLossPct();
    final tp = await SharedPrefsService.getOptionsTakeProfitPct();
    final ps = await SharedPrefsService.getOptionsPortfolioSize();
    final yr = await SharedPrefsService.getOptionsPrefetchYears();
    final mt = await SharedPrefsService.getOptionsMaxTrades();
    if (!mounted) return;
    setState(() {
      _ibkrPort = port;
      _ibkrClientId = cid;
      _dryRun = dry;
      _stopLossPct = sl.clamp(0.5, 2.0);
      _takeProfitPct = tp.clamp(0.1, 0.9);
      _portfolioSize = ps;
      _prefetchYears = yr;
      _maxTrades = mt.clamp(1, 30);
      _loading = false;
    });
    _clientIdCtrl.text = _ibkrClientId.toString();
    _portfolioCtrl.text = _portfolioSize.toStringAsFixed(0);
  }

  Future<void> _saveAndClose() async {
    // Parse text fields
    final cid = int.tryParse(_clientIdCtrl.text.trim()) ?? _ibkrClientId;
    final ps =
        double.tryParse(_portfolioCtrl.text.replaceAll(',', '').trim()) ??
        _portfolioSize;

    setState(() => _saving = true);
    await SharedPrefsService.setOptionsIbkrPort(_ibkrPort);
    await SharedPrefsService.setOptionsIbkrClientId(cid);
    await SharedPrefsService.setOptionsDryRun(_dryRun);
    await SharedPrefsService.setOptionsStopLossPct(_stopLossPct);
    await SharedPrefsService.setOptionsTakeProfitPct(_takeProfitPct);
    await SharedPrefsService.setOptionsPortfolioSize(ps);
    await SharedPrefsService.setOptionsMaxTrades(_maxTrades);
    await SharedPrefsService.setOptionsPrefetchYears(
      _prefetchYears.isEmpty ? [DateTime.now().year] : _prefetchYears,
    );
    // Reset API client in case server URL changed (no-op here, but good habit)
    OptionsApiService.resetClient();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(UIConstants.paddingXXL),
                children: [
                  _buildIbkrSection(),
                  _buildDivider(),
                  _buildRiskSection(),
                  _buildDivider(),
                  _buildTradesSection(),
                  _buildDivider(),
                  _buildPrefetchSection(),
                  const SizedBox(height: UIConstants.spacingXXL),
                ],
              ),
            ),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildHandle() => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(
      UIConstants.paddingXXL,
      UIConstants.paddingM,
      UIConstants.paddingXXL,
      UIConstants.paddingM,
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _accentLight,
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: const Icon(Icons.tune_rounded, color: _accent, size: 20),
        ),
        const SizedBox(width: UIConstants.spacingL),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Options Configuration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: UIConstants.fontXL,
                ),
              ),
              Text(
                'IBKR connection, risk management, prefetch',
                style: TextStyle(
                  color: AppColors.grey500,
                  fontSize: UIConstants.fontM,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey600),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Widget _buildSaveBar() => Container(
    padding: const EdgeInsets.all(UIConstants.paddingXXL),
    decoration: BoxDecoration(
      color: AppColors.white,
      boxShadow: [
        BoxShadow(
          color: AppColors.grey200,
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveAndClose,
            icon:
                _saving
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.save_rounded, size: UIConstants.iconM),
            label: Text(_saving ? 'Saving…' : 'Save Configuration'),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(
                vertical: UIConstants.paddingM,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingXXL),
    child: const Divider(color: AppColors.grey200),
  );

  // ---------------------------------------------------------------------------
  // IBKR Connection
  // ---------------------------------------------------------------------------

  Widget _buildIbkrSection() {
    final isPaper = _ibkrPort == 7497;
    return _Section(
      icon: Icons.account_balance_rounded,
      title: 'IBKR Connection',
      subtitle: 'Interactive Brokers TWS / Gateway settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paper / Live toggle
          Row(
            children: [
              _ModeChip(
                label: 'Paper Trading',
                sublabel: 'Port 7497',
                icon: Icons.science_outlined,
                color: _paperGreen,
                selected: isPaper,
                onTap: () => setState(() => _ibkrPort = 7497),
              ),
              const SizedBox(width: UIConstants.spacingL),
              _ModeChip(
                label: 'Live Trading',
                sublabel: 'Port 7496',
                icon: Icons.bolt_rounded,
                color: _liveRed,
                selected: !isPaper,
                onTap: () => setState(() => _ibkrPort = 7496),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingXXL),
          // Test Mode toggle
          _ToggleRow(
            title: 'Test Mode',
            subtitle: 'Simulates execution — no orders sent to IBKR',
            icon: Icons.science_outlined,
            value: _dryRun,
            onChanged: (v) => setState(() => _dryRun = v),
          ),
          const SizedBox(height: UIConstants.spacingXXL),
          // Client ID
          _LabeledField(
            label: 'Client ID',
            hint: '1',
            controller: _clientIdCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          if (!isPaper)
            Padding(
              padding: const EdgeInsets.only(top: UIConstants.spacingL),
              child: _WarningBanner(
                'Live trading is active — real money orders will be placed.',
              ),
            ),
          if (_dryRun)
            Padding(
              padding: const EdgeInsets.only(top: UIConstants.spacingL),
              child: _InfoBanner(
                'Test Mode: execution logic runs but no real orders are sent to IBKR.',
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Risk Management
  // ---------------------------------------------------------------------------

  Widget _buildRiskSection() {
    return _Section(
      icon: Icons.shield_outlined,
      title: 'Risk Management',
      subtitle: 'Stop-loss, take-profit, and portfolio allocation',
      child: Column(
        children: [
          _SliderRow(
            label: 'Stop-Loss',
            value: _stopLossPct,
            min: 0.5,
            max: 2.0,
            divisions: 30,
            format: (v) => '${(v * 100).round()}% of max loss',
            color: _liveRed,
            onChanged: (v) => setState(() => _stopLossPct = v),
          ),
          const SizedBox(height: UIConstants.spacingXXL),
          _SliderRow(
            label: 'Take-Profit',
            value: _takeProfitPct,
            min: 0.1,
            max: 0.9,
            divisions: 16,
            format: (v) => '${(v * 100).round()}% of max profit',
            color: _paperGreen,
            onChanged: (v) => setState(() => _takeProfitPct = v),
          ),
          const SizedBox(height: UIConstants.spacingXXL),
          _LabeledField(
            label: 'Portfolio Size (USD)',
            hint: '250000',
            controller: _portfolioCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefix: '\$',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Max Trades
  // ---------------------------------------------------------------------------

  Widget _buildTradesSection() {
    return _Section(
      icon: Icons.format_list_numbered_rounded,
      title: 'Max Recommendations',
      subtitle: 'Maximum number of trades shown after generating',
      child: _SliderRow(
        label: 'Max Trades',
        value: _maxTrades.toDouble(),
        min: 1,
        max: 30,
        divisions: 29,
        format: (v) => '${v.round()} trades',
        color: _accent,
        onChanged: (v) => setState(() => _maxTrades = v.round()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Prefetch
  // ---------------------------------------------------------------------------

  Widget _buildPrefetchSection() {
    return _Section(
      icon: Icons.download_rounded,
      title: 'Prefetch Settings',
      subtitle: 'ThetaData years to include in manual prefetch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Years to fetch',
            style: const TextStyle(
              fontSize: UIConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingL),
          Wrap(
            spacing: UIConstants.spacingL,
            children:
                _availableYears.map((y) {
                  final selected = _prefetchYears.contains(y);
                  return FilterChip(
                    label: Text(y.toString()),
                    selected: selected,
                    selectedColor: _accentLight,
                    checkmarkColor: _accent,
                    side: BorderSide(
                      color: selected ? _accent : AppColors.grey300,
                    ),
                    onSelected: (on) {
                      setState(() {
                        if (on) {
                          _prefetchYears = [..._prefetchYears, y]..sort();
                        } else {
                          _prefetchYears =
                              _prefetchYears.where((e) => e != y).toList();
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _accentLight,
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(icon, color: _accent, size: UIConstants.iconM),
            ),
            const SizedBox(width: UIConstants.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: UIConstants.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: UIConstants.fontM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingXXL),
        child,
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: UIConstants.animationFast,
          padding: const EdgeInsets.all(UIConstants.paddingM),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : AppColors.grey50,
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            border: Border.all(
              color: selected ? color : AppColors.grey300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: selected ? color : AppColors.grey500,
                    size: UIConstants.iconM,
                  ),
                  const SizedBox(width: UIConstants.spacingM),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: color, size: 14),
                ],
              ),
              const SizedBox(height: UIConstants.spacingM),
              Text(
                label,
                style: TextStyle(
                  fontSize: UIConstants.fontM,
                  fontWeight: FontWeight.bold,
                  color: selected ? color : AppColors.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: UIConstants.fontXS,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: UIConstants.iconM, color: AppColors.grey500),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: UIConstants.fontL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: UIConstants.fontM,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeTrackColor: _accent),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: UIConstants.fontL,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingM,
                vertical: UIConstants.paddingXS,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusCircular),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                format(value),
                style: TextStyle(
                  fontSize: UIConstants.fontS,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            inactiveTrackColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? prefix;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.inputFormatters,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: UIConstants.fontL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingM),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingM,
              vertical: UIConstants.paddingM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
              borderSide: const BorderSide(color: _accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: _liveRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: _liveRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: _liveRed,
            size: UIConstants.iconM,
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: UIConstants.fontM,
                color: _liveRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _accent,
            size: UIConstants.iconM,
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: UIConstants.fontM,
                color: _accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
