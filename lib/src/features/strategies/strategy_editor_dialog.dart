import 'package:flutter/material.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';

Future<bool?> showStrategyEditorDialog(
  BuildContext context, {
  StrategyItem? initial,
  required Future<bool> Function(Map<String, dynamic> payload) onSubmit,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (dialogContext) =>
            _StrategyEditorDialog(initial: initial, onSubmit: onSubmit),
  );
}

const List<String> _supportedIndicators = <String>[
  'close',
  'open',
  'high',
  'low',
  'volume',
  'vwap',
  'ema20',
  'ema50',
  'rsi',
  'macd',
  'macd_signal',
  'bb_upper',
  'bb_lower',
  'atr',
  'adx',
  'volume_spike',
];

final Set<String> _supportedIndicatorsSet =
    _supportedIndicators.map((s) => s.toLowerCase()).toSet();

const List<String> _supportedOperators = <String>[
  '>',
  '<',
  '>=',
  '<=',
  '==',
  '!=',
];

enum _RhsType { value, compareTo, expression }

class _RuleDraft {
  String indicator;
  String operator;
  _RhsType rhsType;

  final TextEditingController valueController;
  String compareTo;
  final TextEditingController expressionController;

  _RuleDraft({
    required this.indicator,
    required this.operator,
    required this.rhsType,
    required this.valueController,
    required this.compareTo,
    required this.expressionController,
  });

  void dispose() {
    valueController.dispose();
    expressionController.dispose();
  }
}

class _StrategyEditorDialog extends StatefulWidget {
  final StrategyItem? initial;
  final Future<bool> Function(Map<String, dynamic> payload) onSubmit;

  const _StrategyEditorDialog({required this.initial, required this.onSubmit});

  @override
  State<_StrategyEditorDialog> createState() => _StrategyEditorDialogState();
}

class _StrategyEditorDialogState extends State<_StrategyEditorDialog> {
  late final TextEditingController _nameController;
  bool _enabled = true;
  String? _validationErrorMessage;
  bool _isSaving = false;

  final List<_RuleDraft> _preFilters = <_RuleDraft>[];
  final List<_RuleDraft> _buyRules = <_RuleDraft>[];
  final List<_RuleDraft> _sellRules = <_RuleDraft>[];

  late final TextEditingController _stopLossAtrMultController;
  late final TextEditingController _takeProfitAtrMultController;
  late final TextEditingController _minRiskRewardController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _enabled = initial?.enabled ?? true;

    final config = (initial?.config ?? _defaultConfigTemplate());
    _hydrateFromConfig(config);
  }

  void _hydrateFromConfig(Map<String, dynamic> config) {
    final preFilters = config['pre_filters'];
    if (preFilters is List) {
      for (final rule in preFilters.whereType<Map>()) {
        _preFilters.add(_ruleFromJson(rule.cast<String, dynamic>()));
      }
    }

    final buyRules = config['buy_rules'];
    if (buyRules is List) {
      for (final rule in buyRules.whereType<Map>()) {
        _buyRules.add(_ruleFromJson(rule.cast<String, dynamic>()));
      }
    }
    if (_buyRules.isEmpty) {
      _buyRules.add(_newRule());
    }

    final sellRules = config['sell_rules'];
    if (sellRules is List) {
      for (final rule in sellRules.whereType<Map>()) {
        _sellRules.add(_ruleFromJson(rule.cast<String, dynamic>()));
      }
    }

    final risk = config['risk'];
    final riskMap =
        risk is Map ? risk.cast<String, dynamic>() : <String, dynamic>{};

    _stopLossAtrMultController = TextEditingController(
      text: (riskMap['stop_loss_atr_mult'] ?? 2.0).toString(),
    );
    _takeProfitAtrMultController = TextEditingController(
      text: (riskMap['take_profit_atr_mult'] ?? 4.0).toString(),
    );
    _minRiskRewardController = TextEditingController(
      text: (riskMap['min_risk_reward'] ?? 1.5).toString(),
    );
  }

  _RuleDraft _newRule() {
    return _RuleDraft(
      indicator: _supportedIndicators.first,
      operator: _supportedOperators.first,
      rhsType: _RhsType.value,
      valueController: TextEditingController(text: ''),
      compareTo: _supportedIndicators.first,
      expressionController: TextEditingController(text: ''),
    );
  }

  _RuleDraft _ruleFromJson(Map<String, dynamic> json) {
    final indicator =
        (json['indicator'] ?? _supportedIndicators.first).toString();
    final operator = (json['operator'] ?? _supportedOperators.first).toString();

    if (json.containsKey('compare_to')) {
      return _RuleDraft(
        indicator:
            _supportedIndicators.contains(indicator)
                ? indicator
                : _supportedIndicators.first,
        operator:
            _supportedOperators.contains(operator)
                ? operator
                : _supportedOperators.first,
        rhsType: _RhsType.compareTo,
        valueController: TextEditingController(text: ''),
        compareTo:
            (json['compare_to'] ?? _supportedIndicators.first).toString(),
        expressionController: TextEditingController(text: ''),
      );
    }

    if (json.containsKey('expression')) {
      return _RuleDraft(
        indicator:
            _supportedIndicators.contains(indicator)
                ? indicator
                : _supportedIndicators.first,
        operator:
            _supportedOperators.contains(operator)
                ? operator
                : _supportedOperators.first,
        rhsType: _RhsType.expression,
        valueController: TextEditingController(text: ''),
        compareTo: _supportedIndicators.first,
        expressionController: TextEditingController(
          text: (json['expression'] ?? '').toString(),
        ),
      );
    }

    return _RuleDraft(
      indicator:
          _supportedIndicators.contains(indicator)
              ? indicator
              : _supportedIndicators.first,
      operator:
          _supportedOperators.contains(operator)
              ? operator
              : _supportedOperators.first,
      rhsType: _RhsType.value,
      valueController: TextEditingController(
        text: (json['value'] ?? '').toString(),
      ),
      compareTo: _supportedIndicators.first,
      expressionController: TextEditingController(text: ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final rule in _preFilters) {
      rule.dispose();
    }
    for (final rule in _buyRules) {
      rule.dispose();
    }
    for (final rule in _sellRules) {
      rule.dispose();
    }
    _stopLossAtrMultController.dispose();
    _takeProfitAtrMultController.dispose();
    _minRiskRewardController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>>? _buildRulesOrNull(
    List<_RuleDraft> drafts, {
    required String groupLabel,
  }) {
    final rules = <Map<String, dynamic>>[];
    for (var i = 0; i < drafts.length; i++) {
      final rule = drafts[i];
      final base = <String, dynamic>{
        'indicator': rule.indicator,
        'operator': rule.operator,
      };

      switch (rule.rhsType) {
        case _RhsType.value:
          final raw = rule.valueController.text.trim();
          final lower = raw.isEmpty ? '' : raw.toLowerCase();
          if (lower == 'true') {
            base['value'] = true;
          } else if (lower == 'false') {
            base['value'] = false;
          } else {
            final parsed = double.tryParse(raw);
            base['value'] = parsed ?? 0;
          }
          break;
        case _RhsType.compareTo:
          if (rule.compareTo.trim().isEmpty) return null;
          base['compare_to'] = rule.compareTo.trim();
          break;
        case _RhsType.expression:
          final expr = rule.expressionController.text.trim();
          if (expr.isEmpty) return null;
          final error = _validateExpression(expr);
          if (error != null) {
            _validationErrorMessage ??= '$groupLabel #${i + 1}: $error';
            return null;
          }
          base['expression'] = expr;
          break;
      }

      rules.add(base);
    }
    return rules;
  }

  String? _validateExpression(String expression) {
    final expr = expression.trim();
    if (expr.isEmpty) return AppStrings.invalidExpression;

    final allowedChars = RegExp(r'^[0-9A-Za-z_\s\.\+\-\*/%(),<>!=&|^]+$');
    if (!allowedChars.hasMatch(expr)) {
      return '${AppStrings.invalidExpression}: contains unsupported characters';
    }

    var depth = 0;
    for (final codePoint in expr.runes) {
      if (codePoint == 40) depth++; // (
      if (codePoint == 41) depth--; // )
      if (depth < 0) {
        return '${AppStrings.invalidExpression}: unbalanced parentheses';
      }
    }
    if (depth != 0) {
      return '${AppStrings.invalidExpression}: unbalanced parentheses';
    }

    final compact = expr.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'[\+\-\*/%^]$').hasMatch(compact)) {
      return '${AppStrings.invalidExpression}: cannot end with an operator';
    }

    final allowedFunctions = <String>{
      'abs',
      'min',
      'max',
      'round',
      'floor',
      'ceil',
      'sqrt',
      'log',
      'pow',
    };

    final idRe = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
    final unknown = <String>{};
    for (final match in idRe.allMatches(expr)) {
      final token = match.group(0) ?? '';
      if (token.isEmpty) continue;
      final normalized = token.toLowerCase();

      if (_supportedIndicatorsSet.contains(normalized) ||
          normalized == 'true' ||
          normalized == 'false') {
        continue;
      }

      if (allowedFunctions.contains(normalized)) {
        final rest = expr.substring(match.end).trimLeft();
        if (rest.startsWith('(')) continue;
      }

      unknown.add(token);
    }

    if (unknown.isNotEmpty) {
      final shown = unknown.take(4).join(', ');
      final hint = _supportedIndicators.take(6).join(', ');
      return '${AppStrings.invalidExpression}: unknown identifier(s): $shown. Use supported indicators like $hint.';
    }

    return null;
  }

  Map<String, dynamic>? _buildConfigOrNull() {
    final preFilters =
        _preFilters.isEmpty
            ? <Map<String, dynamic>>[]
            : _buildRulesOrNull(_preFilters, groupLabel: AppStrings.preFilters);
    if (preFilters == null) return null;

    final buyRules = _buildRulesOrNull(
      _buyRules,
      groupLabel: AppStrings.buyRules,
    );
    if (buyRules == null || buyRules.isEmpty) return null;

    final sellRules =
        _sellRules.isEmpty
            ? <Map<String, dynamic>>[]
            : _buildRulesOrNull(_sellRules, groupLabel: AppStrings.sellRules);
    if (sellRules == null) return null;

    final stopLoss = double.tryParse(_stopLossAtrMultController.text.trim());
    final takeProfit = double.tryParse(
      _takeProfitAtrMultController.text.trim(),
    );
    final minRR = double.tryParse(_minRiskRewardController.text.trim());

    final effectiveStopLoss = stopLoss ?? 2.0;
    final effectiveTakeProfit = takeProfit ?? 4.0;
    final effectiveMinRR = minRR ?? 1.5;

    final config = <String, dynamic>{
      'buy_rules': buyRules,
      'risk': <String, dynamic>{
        'stop_loss_atr_mult': effectiveStopLoss,
        'take_profit_atr_mult': effectiveTakeProfit,
        'min_risk_reward': effectiveMinRR,
      },
    };
    if (preFilters.isNotEmpty) {
      config['pre_filters'] = preFilters;
    }
    if (sellRules.isNotEmpty) {
      config['sell_rules'] = sellRules;
    }
    return config;
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationErrorMessage = AppStrings.strategyNameRequired);
      return;
    }

    final config = _buildConfigOrNull();
    if (config == null) {
      setState(() {
        _validationErrorMessage ??= AppStrings.strategyRulesInvalid;
      });
      return;
    }

    final payload = <String, dynamic>{
      'name': name,
      'enabled': _enabled,
      'config': config,
    };

    setState(() {
      _validationErrorMessage = null;
      _isSaving = true;
    });

    final ok = await widget.onSubmit(payload);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
      _validationErrorMessage =
          widget.initial == null
              ? AppStrings.strategyCreateFailed
              : AppStrings.strategyUpdateFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initial;

    return PopScope(
      canPop: !_isSaving,
      child: AlertDialog(
        title: Text(
          initial == null ? AppStrings.createStrategy : AppStrings.editStrategy,
        ),
        content: SizedBox(
          width: 640,
          child: AbsorbPointer(
            absorbing: _isSaving,
            child: Builder(
              builder: (context) {
                const errorBannerMaxHeight = 140.0;
                const errorBannerSpacing = 12.0;
                final topPadding =
                    _validationErrorMessage == null
                        ? 0.0
                        : errorBannerMaxHeight + errorBannerSpacing;

                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: AppStrings.strategyName,
                                border: OutlineInputBorder(),
                              ),
                              onChanged:
                                  (_) => setState(
                                    () => _validationErrorMessage = null,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _enabled,
                              onChanged:
                                  (v) => setState(() {
                                    _enabled = v;
                                    _validationErrorMessage = null;
                                  }),
                              title: const Text(AppStrings.enabled),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.strategyRules,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.strategyRulesHint,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.preFilters,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            if (_preFilters.isEmpty)
                              Text(
                                AppStrings.preFiltersOptional,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              )
                            else
                              ..._preFilters.asMap().entries.map((entry) {
                                final index = entry.key;
                                final rule = entry.value;
                                return _RuleCard(
                                  index: index,
                                  rule: rule,
                                  onChanged:
                                      () => setState(
                                        () => _validationErrorMessage = null,
                                      ),
                                  onDelete: () {
                                    setState(() {
                                      _validationErrorMessage = null;
                                      rule.dispose();
                                      _preFilters.removeAt(index);
                                    });
                                  },
                                );
                              }),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => setState(() {
                                      _validationErrorMessage = null;
                                      _preFilters.add(_newRule());
                                    }),
                                icon: const Icon(Icons.add),
                                label: const Text(AppStrings.addRule),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.buyRules,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            ..._buyRules.asMap().entries.map((entry) {
                              final index = entry.key;
                              final rule = entry.value;
                              return _RuleCard(
                                index: index,
                                rule: rule,
                                onChanged:
                                    () => setState(
                                      () => _validationErrorMessage = null,
                                    ),
                                onDelete:
                                    _buyRules.length <= 1
                                        ? null
                                        : () {
                                          setState(() {
                                            _validationErrorMessage = null;
                                            rule.dispose();
                                            _buyRules.removeAt(index);
                                          });
                                        },
                              );
                            }),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => setState(() {
                                      _validationErrorMessage = null;
                                      _buyRules.add(_newRule());
                                    }),
                                icon: const Icon(Icons.add),
                                label: const Text(AppStrings.addRule),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.sellRules,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            if (_sellRules.isEmpty)
                              Text(
                                AppStrings.sellRulesOptional,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              )
                            else
                              ..._sellRules.asMap().entries.map((entry) {
                                final index = entry.key;
                                final rule = entry.value;
                                return _RuleCard(
                                  index: index,
                                  rule: rule,
                                  onChanged:
                                      () => setState(
                                        () => _validationErrorMessage = null,
                                      ),
                                  onDelete: () {
                                    setState(() {
                                      _validationErrorMessage = null;
                                      rule.dispose();
                                      _sellRules.removeAt(index);
                                    });
                                  },
                                );
                              }),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => setState(() {
                                      _validationErrorMessage = null;
                                      _sellRules.add(_newRule());
                                    }),
                                icon: const Icon(Icons.add),
                                label: const Text(AppStrings.addRule),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.risk,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _stopLossAtrMultController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.stopLossAtrMult,
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged:
                                        (_) => setState(
                                          () => _validationErrorMessage = null,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _takeProfitAtrMultController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.takeProfitAtrMult,
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged:
                                        (_) => setState(
                                          () => _validationErrorMessage = null,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _minRiskRewardController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: AppStrings.minRiskReward,
                                border: OutlineInputBorder(),
                              ),
                              onChanged:
                                  (_) => setState(
                                    () => _validationErrorMessage = null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_validationErrorMessage != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: errorBannerMaxHeight,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      _validationErrorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  iconSize: 18,
                                  tooltip: AppStrings.clear,
                                  onPressed:
                                      () => setState(
                                        () => _validationErrorMessage = null,
                                      ),
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
            ),
            child:
                _isSaving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                    : Text(
                      initial == null
                          ? AppStrings.createStrategy
                          : AppStrings.save,
                    ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final int index;
  final _RuleDraft rule;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  const _RuleCard({
    required this.index,
    required this.rule,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('${AppStrings.rule} ${index + 1}'),
                const Spacer(),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: AppStrings.delete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(AppStrings.indicator, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _supportedIndicators.map((k) {
                    final selected = rule.indicator == k;
                    return ChoiceChip(
                      label: Text(k),
                      selected: selected,
                      onSelected: (_) {
                        rule.indicator = k;
                        if (!_supportedIndicators.contains(rule.compareTo)) {
                          rule.compareTo = _supportedIndicators.first;
                        }
                        onChanged();
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Text(AppStrings.operator, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _supportedOperators.map((op) {
                    final selected = rule.operator == op;
                    return ChoiceChip(
                      label: Text(op),
                      selected: selected,
                      onSelected: (_) {
                        rule.operator = op;
                        onChanged();
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.rightHandSide,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text(AppStrings.value),
                  selected: rule.rhsType == _RhsType.value,
                  onSelected: (_) {
                    rule.rhsType = _RhsType.value;
                    onChanged();
                  },
                ),
                ChoiceChip(
                  label: const Text(AppStrings.compareTo),
                  selected: rule.rhsType == _RhsType.compareTo,
                  onSelected: (_) {
                    rule.rhsType = _RhsType.compareTo;
                    onChanged();
                  },
                ),
                ChoiceChip(
                  label: const Text(AppStrings.expression),
                  selected: rule.rhsType == _RhsType.expression,
                  onSelected: (_) {
                    rule.rhsType = _RhsType.expression;
                    onChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rule.rhsType == _RhsType.value)
              TextField(
                controller: rule.valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: AppStrings.value,
                  hintText: 'e.g. 30 or true',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              )
            else if (rule.rhsType == _RhsType.compareTo) ...[
              Text(AppStrings.compareTo, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _supportedIndicators.map((k) {
                      final selected = rule.compareTo == k;
                      return ChoiceChip(
                        label: Text(k),
                        selected: selected,
                        onSelected: (_) {
                          rule.compareTo = k;
                          onChanged();
                        },
                      );
                    }).toList(),
              ),
            ] else
              TextField(
                controller: rule.expressionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.expression,
                  hintText: 'e.g. ema20 + atr',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _defaultConfigTemplate() {
  return {
    'pre_filters': [
      {'indicator': 'volume_spike', 'operator': '==', 'value': true},
    ],
    'buy_rules': [
      {'indicator': 'ema20', 'operator': '>', 'compare_to': 'ema50'},
    ],
    'sell_rules': [
      {'indicator': 'ema20', 'operator': '<', 'compare_to': 'ema50'},
    ],
    'risk': {
      'stop_loss_atr_mult': 2.0,
      'take_profit_atr_mult': 4.0,
      'min_risk_reward': 1.5,
    },
  };
}
