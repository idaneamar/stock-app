import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/services/options_api_service.dart';

const Color _accent = Color(0xFF4F78FF);

// ---------------------------------------------------------------------------
// Entry point — show as bottom sheet
// ---------------------------------------------------------------------------

Future<void> showOptionsActivityPanel(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OptionsActivitySheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class _OptionsActivitySheet extends StatefulWidget {
  const _OptionsActivitySheet();

  @override
  State<_OptionsActivitySheet> createState() => _OptionsActivitySheetState();
}

class _OptionsActivitySheetState extends State<_OptionsActivitySheet> {
  final OptionsApiService _service = OptionsApiService();
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;
  String _error = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Auto-refresh every 10 seconds while open
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final logs = await _service.getJobLogs(limit: 60);
      if (mounted) {
        setState(() {
          _logs = logs;
          _loading = false;
          _error = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingXXL,
              vertical: UIConstants.paddingM,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: const Icon(
                    Icons.terminal_rounded,
                    color: _accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingL),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: UIConstants.fontXL,
                        ),
                      ),
                      Text(
                        'Script execution log · auto-refreshes every 10s',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: UIConstants.fontM,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _fetch();
                  },
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey600),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty && _logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: UIConstants.iconHuge,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: UIConstants.spacingXXL),
            FilledButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_logs.isEmpty) {
      return Center(
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
              'No activity yet',
              style: TextStyle(
                fontSize: UIConstants.fontXXL,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            const Text(
              'Jobs will appear here once the scheduler runs\nor you trigger a script manually.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingXXL,
        vertical: UIConstants.paddingL,
      ),
      itemCount: _logs.length,
      separatorBuilder:
          (_, __) => const Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (_, i) => _JobLogTile(entry: _logs[i], onCancelled: _fetch),
    );
  }
}

// ---------------------------------------------------------------------------
// Script name → API parameter mapping
// ---------------------------------------------------------------------------

const _scriptFileNames = {
  'Generate Recommendations (optsp)': 'optsp.py',
  'Prefetch Options Data': 'prefetch_options_datasp.py',
  'Fetch S&P 500 Symbols': 'fetch_sp500_symbols.py',
};

// ---------------------------------------------------------------------------
// Single job entry tile
// ---------------------------------------------------------------------------

class _JobLogTile extends StatefulWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onCancelled;
  const _JobLogTile({required this.entry, this.onCancelled});

  @override
  State<_JobLogTile> createState() => _JobLogTileState();
}

class _JobLogTileState extends State<_JobLogTile> {
  bool _expanded = false;
  bool _cancelling = false;

  Future<void> _cancelJob(Map<String, dynamic> entry) async {
    final label = entry['label'] as String? ?? '';
    final scriptFile = _scriptFileNames[label] ?? entry['script'] as String?;
    if (scriptFile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Cancel job?'),
            content: Text('Stop "$label" now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes, cancel'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await OptionsApiService().cancelScript(script: scriptFile);
      await Future.delayed(const Duration(seconds: 1));
      widget.onCancelled?.call();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.entry['status'] as String? ?? 'unknown';
    final label =
        widget.entry['label'] as String? ?? widget.entry['script'] ?? '?';
    final startedAt = widget.entry['started_at'] as String?;
    // ignore: unused_local_variable
    final endedAt = widget.entry['ended_at'] as String?;
    final durationS = widget.entry['duration_s'];
    final summary = widget.entry['summary'] as String?;
    final stdout = widget.entry['stdout_tail'] as String? ?? '';
    final stderr = widget.entry['stderr_tail'] as String? ?? '';
    final args = (widget.entry['args'] as List?)?.join(' ') ?? '';

    final statusIcon = _statusIcon(status);
    final statusColor = _statusColor(status);
    final timeStr = _formatTime(startedAt);
    final durStr = durationS != null ? '${durationS}s' : '';

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(UIConstants.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row
            Row(
              children: [
                // Status indicator
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        status == 'running' ? Colors.transparent : statusColor,
                    shape: BoxShape.circle,
                    border:
                        status == 'running'
                            ? Border.all(color: statusColor, width: 2)
                            : null,
                  ),
                  child:
                      status == 'running'
                          ? Padding(
                            padding: const EdgeInsets.all(1),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: statusColor,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: UIConstants.spacingL),
                // Icon
                Icon(statusIcon, size: UIConstants.iconM, color: statusColor),
                const SizedBox(width: UIConstants.spacingM),
                // Label
                Expanded(
                  child: Column(
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
                      if (args.isNotEmpty)
                        Text(
                          args,
                          style: const TextStyle(
                            fontSize: UIConstants.fontS,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                ),
                // Time + duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: UIConstants.fontS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (durStr.isNotEmpty)
                      Text(
                        durStr,
                        style: TextStyle(
                          fontSize: UIConstants.fontXS,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: UIConstants.spacingM),
                // Cancel button — only for running jobs
                if (status == 'running') ...[
                  _cancelling
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Tooltip(
                        message: 'Cancel this job',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _cancelJob(widget.entry),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.cancel_outlined,
                              size: UIConstants.iconM,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(width: UIConstants.spacingS),
                ],
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: UIConstants.iconM,
                  color: AppColors.grey400,
                ),
              ],
            ),

            // Summary line
            if (summary != null && summary.isNotEmpty) ...[
              const SizedBox(height: UIConstants.spacingS),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  summary,
                  style: TextStyle(
                    fontSize: UIConstants.fontM,
                    color: statusColor,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Expanded output
            if (_expanded) ...[
              const SizedBox(height: UIConstants.spacingL),
              _OutputBox(label: 'Output', text: stdout),
              if (stderr.isNotEmpty) ...[
                const SizedBox(height: UIConstants.spacingM),
                _OutputBox(label: 'Errors', text: stderr, isError: true),
              ],
            ],
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'running':
        return Icons.play_circle_outline_rounded;
      case 'ok':
        return Icons.check_circle_outline_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      case 'timeout':
        return Icons.timer_off_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'running':
        return const Color(0xFF4F78FF);
      case 'ok':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'timeout':
        return AppColors.warning;
      default:
        return AppColors.grey500;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.substring(0, 16).replaceAll('T', ' ');
    }
  }
}

// ---------------------------------------------------------------------------
// Output box (terminal-style)
// ---------------------------------------------------------------------------

class _OutputBox extends StatelessWidget {
  final String label;
  final String text;
  final bool isError;

  const _OutputBox({
    required this.label,
    required this.text,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.fontXS,
            fontWeight: FontWeight.w600,
            color: isError ? AppColors.error : AppColors.grey600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UIConstants.paddingM),
          decoration: BoxDecoration(
            color: isError ? AppColors.errorLight : const Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: SelectableText(
            text.isEmpty ? '(no output)' : text,
            style: TextStyle(
              fontSize: UIConstants.fontXS,
              fontFamily: 'monospace',
              color: isError ? AppColors.error : Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
