import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

const Color _accent = Color(0xFF4F78FF);
const Color _successGreen = Color(0xFF059669);
const Color _errorRed = Color(0xFFDC2626);
const Color _dryRunOrange = Color(0xFFF59E0B);
const Color _terminalBg = Color(0xFF0F1117);
const Color _terminalBgAlt = Color(0xFF1A1F36);

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class IbkrExecutionResult {
  final bool ok;
  final bool dryRun;
  final String stdout;
  final String stderr;
  final String message;
  final int returnCode;
  final String? recDate;
  final List<String>? tickers;

  const IbkrExecutionResult({
    required this.ok,
    required this.dryRun,
    required this.stdout,
    required this.stderr,
    required this.message,
    required this.returnCode,
    this.recDate,
    this.tickers,
  });
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> showIbkrLogSheet(
  BuildContext context,
  IbkrExecutionResult result,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IbkrLogSheet(result: result),
  );
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class _IbkrLogSheet extends StatefulWidget {
  final IbkrExecutionResult result;
  const _IbkrLogSheet({required this.result});

  @override
  State<_IbkrLogSheet> createState() => _IbkrLogSheetState();
}

class _IbkrLogSheetState extends State<_IbkrLogSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  IbkrExecutionResult get r => widget.result;

  Color get _statusColor {
    if (r.dryRun) return _dryRunOrange;
    return r.ok ? _successGreen : _errorRed;
  }

  IconData get _statusIcon {
    if (r.dryRun) return Icons.science_outlined;
    return r.ok ? Icons.check_circle_rounded : Icons.error_rounded;
  }

  String get _statusLabel {
    if (r.dryRun) return 'DRY RUN';
    return r.ok ? 'SUCCESS' : 'FAILED';
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.82,
      decoration: const BoxDecoration(
        color: _terminalBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildStatusBanner(),
          if (r.tickers != null && r.tickers!.isNotEmpty) _buildTickerRow(),
          _buildTabBar(),
          const SizedBox(height: 1),
          Expanded(child: _buildTabView()),
          _buildBottomBar(),
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
          color: Colors.white24,
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
            color: Colors.white12,
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: const Icon(
            Icons.terminal_rounded,
            color: Colors.white70,
            size: UIConstants.iconM,
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IBKR Execution Log',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: UIConstants.fontXL,
                  color: Colors.white,
                ),
              ),
              Text(
                r.recDate != null
                    ? 'Recommendations: ${r.recDate}'
                    : 'Latest recommendations',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: UIConstants.fontM,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Widget _buildStatusBanner() => Container(
    margin: const EdgeInsets.symmetric(
      horizontal: UIConstants.paddingXXL,
      vertical: UIConstants.paddingS,
    ),
    padding: const EdgeInsets.all(UIConstants.paddingM),
    decoration: BoxDecoration(
      color: _statusColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(UIConstants.radiusS),
      border: Border.all(color: _statusColor.withValues(alpha: 0.4)),
    ),
    child: Row(
      children: [
        Icon(_statusIcon, color: _statusColor, size: UIConstants.iconM),
        const SizedBox(width: UIConstants.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _statusLabel,
            style: const TextStyle(
              fontSize: UIConstants.fontXS,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: Text(
            r.message,
            style: TextStyle(
              fontSize: UIConstants.fontM,
              color: _statusColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          'rc=${r.returnCode}',
          style: TextStyle(
            fontSize: UIConstants.fontXS,
            color: _statusColor.withValues(alpha: 0.7),
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );

  Widget _buildTickerRow() => Padding(
    padding: const EdgeInsets.fromLTRB(
      UIConstants.paddingXXL,
      UIConstants.paddingXS,
      UIConstants.paddingXXL,
      UIConstants.paddingS,
    ),
    child: Wrap(
      spacing: UIConstants.spacingM,
      runSpacing: UIConstants.spacingS,
      children:
          r.tickers!
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      UIConstants.radiusCircular,
                    ),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: UIConstants.fontS,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              )
              .toList(),
    ),
  );

  Widget _buildTabBar() => Container(
    color: _terminalBgAlt,
    child: TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      indicatorColor: _accent,
      indicatorWeight: 2,
      tabs: [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.output_rounded, size: 14),
              const SizedBox(width: 6),
              const Text('stdout'),
              if (r.stdout.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _LineCountBadge(
                    count: r.stdout.split('\n').length,
                    color: _successGreen,
                  ),
                ),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 14),
              const SizedBox(width: 6),
              const Text('stderr'),
              if (r.stderr.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _LineCountBadge(
                    count: r.stderr.split('\n').length,
                    color: _errorRed,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTabView() => TabBarView(
    controller: _tabCtrl,
    children: [
      _TerminalPane(
        text: r.stdout.isEmpty ? '(no output)' : r.stdout,
        isError: false,
      ),
      _TerminalPane(
        text: r.stderr.isEmpty ? '(no stderr)' : r.stderr,
        isError: true,
      ),
    ],
  );

  Widget _buildBottomBar() => Container(
    color: _terminalBgAlt,
    padding: const EdgeInsets.symmetric(
      horizontal: UIConstants.paddingXXL,
      vertical: UIConstants.paddingM,
    ),
    child: Row(
      children: [
        // Copy stdout
        _TerminalButton(
          icon: Icons.copy_rounded,
          label: 'Copy Output',
          onTap: () {
            Clipboard.setData(ClipboardData(text: r.stdout));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Output copied to clipboard'),
                duration: Duration(seconds: 2),
                backgroundColor: _successGreen,
              ),
            );
          },
        ),
        const SizedBox(width: UIConstants.spacingL),
        // Copy full log
        _TerminalButton(
          icon: Icons.file_copy_outlined,
          label: 'Copy All',
          onTap: () {
            final all = 'STDOUT:\n${r.stdout}\n\nSTDERR:\n${r.stderr}';
            Clipboard.setData(ClipboardData(text: all));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Full log copied to clipboard'),
                duration: Duration(seconds: 2),
                backgroundColor: _accent,
              ),
            );
          },
        ),
        const Spacer(),
        // Close
        _TerminalButton(
          icon: Icons.close_rounded,
          label: 'Close',
          onTap: () => Navigator.of(context).pop(),
          primary: true,
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Terminal pane
// ---------------------------------------------------------------------------

class _TerminalPane extends StatelessWidget {
  final String text;
  final bool isError;

  const _TerminalPane({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Container(
      color: _terminalBg,
      child: ListView.builder(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        itemCount: lines.length,
        itemBuilder: (_, i) {
          final line = lines[i];
          final lineColor = _lineColor(line, isError);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: SelectableText(
              line.isEmpty ? ' ' : line,
              style: TextStyle(
                fontSize: UIConstants.fontS,
                fontFamily: 'monospace',
                color: lineColor,
                height: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _lineColor(String line, bool isError) {
    final lower = line.toLowerCase();
    if (isError) {
      if (lower.contains('error') ||
          lower.contains('exception') ||
          lower.contains('failed')) {
        return _errorRed;
      }
      if (lower.contains('warning') || lower.contains('warn')) {
        return _dryRunOrange;
      }
      return Colors.white54;
    }
    // stdout coloring
    if (lower.contains('error') || lower.contains('fail')) {
      return _errorRed;
    }
    if (lower.contains('warning') || lower.contains('warn')) {
      return _dryRunOrange;
    }
    if (lower.contains('placed') ||
        lower.contains('executed') ||
        lower.contains('submitted') ||
        lower.contains('done') ||
        lower.contains('success') ||
        lower.contains('order')) {
      return _successGreen;
    }
    if (line.startsWith('  ') || lower.contains('info')) {
      return Colors.white70;
    }
    return Colors.white54;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _LineCountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _LineCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: UIConstants.fontXS,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TerminalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _TerminalButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingM,
          vertical: UIConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: primary ? _accent.withValues(alpha: 0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(UIConstants.radiusS),
          border: Border.all(
            color: primary ? _accent.withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: UIConstants.iconXS,
              color: primary ? _accent : Colors.white54,
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.fontS,
                color: primary ? _accent : Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
