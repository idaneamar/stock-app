import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/options/options_ai_panel.dart';
import 'package:stock_app/src/features/options/options_dashboard_screen.dart'
    show IronCondorCard;
import 'package:stock_app/src/features/options/options_history_controller.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

const Color _accent = Color(0xFF4F78FF);
const Color _accentLight = Color(0xFFEEF2FF);

class OptionsHistoryScreen extends StatelessWidget {
  const OptionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OptionsHistoryController());

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          _HistoryHeader(ctrl: ctrl),
          _DateNavigator(ctrl: ctrl),
          _TickerFilter(ctrl: ctrl),
          Expanded(child: _HistoryBody(ctrl: ctrl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HistoryHeader extends StatelessWidget {
  final OptionsHistoryController ctrl;
  const _HistoryHeader({required this.ctrl});

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
              Icons.history_rounded,
              color: _accent,
              size: UIConstants.iconXL,
            ),
          ),
          const SizedBox(width: UIConstants.spacingXL),
          const Expanded(
            child: Text(
              'Recommendations History',
              style: TextStyle(
                fontSize: UIConstants.fontXXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
                        recDate: ctrl.selectedDate.value,
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
          IconButton(
            onPressed: ctrl.refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date navigator
// ---------------------------------------------------------------------------

class _DateNavigator extends StatelessWidget {
  final OptionsHistoryController ctrl;
  const _DateNavigator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        UIConstants.paddingXXL,
        0,
        UIConstants.paddingXXL,
        UIConstants.paddingL,
      ),
      child: Row(
        children: [
          // Previous date arrow
          Obx(
            () => IconButton(
              onPressed: ctrl.hasPrev ? ctrl.navigateToPrevDate : null,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Earlier date',
              style: IconButton.styleFrom(
                foregroundColor: ctrl.hasPrev ? _accent : AppColors.grey400,
              ),
            ),
          ),

          // Date picker button
          Obx(() {
            final date = ctrl.selectedDate.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(context, ctrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingL,
                    vertical: UIConstants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    border: Border.all(color: _accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: UIConstants.iconM,
                        color: _accent,
                      ),
                      const SizedBox(width: UIConstants.spacingM),
                      Text(
                        date.isNotEmpty ? date : 'Select date',
                        style: const TextStyle(
                          fontSize: UIConstants.fontXL,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Next date arrow
          Obx(
            () => IconButton(
              onPressed: ctrl.hasNext ? ctrl.navigateToNextDate : null,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Later date',
              style: IconButton.styleFrom(
                foregroundColor: ctrl.hasNext ? _accent : AppColors.grey400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    OptionsHistoryController ctrl,
  ) async {
    final dates = ctrl.availableDates;
    if (dates.isEmpty) return;

    final selected = await showDialog<String>(
      context: context,
      builder:
          (ctx) =>
              _DatePickerDialog(dates: dates, current: ctrl.selectedDate.value),
    );
    if (selected != null && selected != ctrl.selectedDate.value) {
      ctrl.loadDate(selected);
    }
  }
}

// ---------------------------------------------------------------------------
// Date picker dialog
// ---------------------------------------------------------------------------

class _DatePickerDialog extends StatelessWidget {
  final List<String> dates;
  final String current;
  const _DatePickerDialog({required this.dates, required this.current});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date'),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 280,
        height: 400,
        child: ListView.builder(
          itemCount: dates.length,
          itemBuilder: (_, i) {
            final d = dates[i];
            final isSelected = d == current;
            return ListTile(
              title: Text(d),
              selected: isSelected,
              selectedColor: _accent,
              leading:
                  isSelected
                      ? const Icon(Icons.check_circle_rounded, color: _accent)
                      : const Icon(
                        Icons.circle_outlined,
                        color: AppColors.grey400,
                      ),
              onTap: () => Navigator.pop(context, d),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ticker filter
// ---------------------------------------------------------------------------

class _TickerFilter extends StatelessWidget {
  final OptionsHistoryController ctrl;
  const _TickerFilter({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        UIConstants.paddingXXL,
        0,
        UIConstants.paddingXXL,
        UIConstants.paddingL,
      ),
      child: TextField(
        onChanged: (v) => ctrl.filterTicker.value = v,
        decoration: InputDecoration(
          hintText: 'Filter by ticker…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Obx(
            () =>
                ctrl.filterTicker.value.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => ctrl.filterTicker.value = '',
                    )
                    : const SizedBox.shrink(),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingL,
            vertical: UIConstants.paddingM,
          ),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _HistoryBody extends StatelessWidget {
  final OptionsHistoryController ctrl;
  const _HistoryBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = ctrl.recsState.value;

      if (ctrl.datesState.value == OptionsHistoryLoadState.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (ctrl.availableDates.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.folder_open_rounded,
                size: UIConstants.iconHuge,
                color: AppColors.grey400,
              ),
              const SizedBox(height: UIConstants.spacingXXL),
              const Text(
                'No recommendation files found',
                style: TextStyle(
                  fontSize: UIConstants.fontXXL,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      if (state == OptionsHistoryLoadState.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state == OptionsHistoryLoadState.error) {
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
                ctrl.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
              FilledButton(
                onPressed: () => ctrl.loadDate(ctrl.selectedDate.value),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final recs = ctrl.filteredRecommendations;

      if (recs.isEmpty) {
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
              Text(
                ctrl.filterTicker.value.isNotEmpty
                    ? 'No results for "${ctrl.filterTicker.value}"'
                    : 'No recommendations for ${ctrl.selectedDate.value}',
                style: const TextStyle(
                  fontSize: UIConstants.fontXXL,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(UIConstants.paddingXXL),
        itemCount: recs.length,
        itemBuilder:
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: UIConstants.paddingL),
              child: IronCondorCard(rec: recs[i], rank: i + 1, readOnly: true),
            ),
      );
    });
  }
}
