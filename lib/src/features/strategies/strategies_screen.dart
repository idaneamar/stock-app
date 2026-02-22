import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/strategies/strategies_controller.dart';
import 'package:stock_app/src/features/strategies/strategy_editor_dialog.dart';
import 'package:stock_app/src/features/strategies/widgets/strategies_error_state.dart';
import 'package:stock_app/src/features/strategies/widgets/strategy_card.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/route/app_router.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';

class StrategiesScreen extends StatefulWidget {
  const StrategiesScreen({super.key});

  @override
  State<StrategiesScreen> createState() => _StrategiesScreenState();
}

class _StrategiesScreenState extends State<StrategiesScreen> {
  final StrategiesController controller = Get.put(StrategiesController());

  @override
  void initState() {
    super.initState();
    controller.fetchStrategies();
    controller.fetchPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.strategies,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            onPressed: () => controller.fetchStrategies(),
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: Container(
        color: AppColors.grey50,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.blue),
                  SizedBox(height: UIConstants.spacingL),
                  Text(
                    'Loading strategies...',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: UIConstants.fontL,
                    ),
                  ),
                ],
              ),
            );
          }
          if (controller.error.value.isNotEmpty) {
            return StrategiesErrorState(
              message: controller.error.value,
              onRetry: () => controller.fetchStrategies(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildProgramCard(context)),
              if (controller.strategies.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: _buildStrategiesListSliver(context),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          AppStrings.createStrategy,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.blue50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 60,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXXL),
            const Text(
              'No Strategies Yet',
              style: TextStyle(
                fontSize: UIConstants.fontHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Text(
              'Create your first trading strategy to get started.\nStrategies help automate your trading decisions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.fontL,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXXL),
            ElevatedButton.icon(
              onPressed: () => _create(context),
              icon: const Icon(Icons.add),
              label: const Text(
                'Create Strategy',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingXXL,
                  vertical: UIConstants.paddingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UIConstants.marginL),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.program,
            style: const TextStyle(
              fontSize: UIConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          Obx(() {
            final items = controller.programs;
            final value = controller.selectedProgramId.value;
            final validIds =
                items.map((p) => (p['program_id'] ?? '').toString()).toSet();
            final displayValue =
                value.isEmpty || !validIds.contains(value) ? '' : value;
            final dropdownItems = <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(
                value: '',
                child: Text(AppStrings.noProgram),
              ),
              ...items.map(
                (p) => DropdownMenuItem<String>(
                  value: (p['program_id'] ?? '').toString(),
                  child: Text(
                    (p['name'] ?? p['program_id'] ?? 'Program').toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ];
            return DropdownButtonFormField<String>(
              value: displayValue,
              decoration: const InputDecoration(
                labelText: AppStrings.selectProgram,
                border: OutlineInputBorder(),
              ),
              items: dropdownItems,
              onChanged: (v) {
                if (v != null) controller.setActiveProgram(v);
              },
            );
          }),
          const SizedBox(height: UIConstants.spacingM),
          OutlinedButton.icon(
            onPressed: () async {
              await Get.toNamed(Routes.createProgram);
              controller.fetchPrograms();
            },
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createProgram),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesListSliver(BuildContext context) {
    final activeCount = controller.strategies.where((s) => s.enabled).length;
    final totalCount = controller.strategies.length;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(UIConstants.marginL),
            padding: const EdgeInsets.all(UIConstants.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue700, AppColors.blue500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Strategies',
                        style: TextStyle(
                          color: AppColors.white70,
                          fontSize: UIConstants.fontL,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Text(
                        '$totalCount ${totalCount == 1 ? 'Strategy' : 'Strategies'}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: UIConstants.fontHeading,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM,
                    vertical: UIConstants.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      UIConstants.radiusCircular,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingS),
                      Text(
                        '$activeCount Active',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: UIConstants.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            UIConstants.paddingL,
            0,
            UIConstants.paddingL,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = controller.strategies[index];
              return StrategyCard(
                strategy: item,
                onToggle:
                    (enabled) => _toggleEnabled(context, item.id, enabled),
                onEdit: () => _edit(context, item.id),
                onDelete: () => _delete(context, item.id),
              );
            }, childCount: controller.strategies.length),
          ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    await showStrategyEditorDialog(
      context,
      onSubmit: controller.createStrategy,
    );
  }

  Future<void> _edit(BuildContext context, int id) async {
    final current = controller.getById(id);
    if (current == null) return;
    await showStrategyEditorDialog(
      context,
      initial: current,
      onSubmit: (payload) => controller.updateStrategy(current.id, payload),
    );
  }

  Future<void> _toggleEnabled(
    BuildContext context,
    int id,
    bool enabled,
  ) async {
    final ok = await controller.updateStrategy(id, {'enabled': enabled});
    if (!context.mounted) return;
    if (!ok) {
      UiFeedback.showSnackBar(
        context,
        message: AppStrings.strategyUpdateFailed,
        type: UiMessageType.error,
      );
    }
  }

  Future<void> _delete(BuildContext context, int id) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: !isDeleting,
              child: AlertDialog(
                title: const Text(AppStrings.delete),
                content: Text('${AppStrings.deleteStrategyConfirm} #$id?'),
                actions: [
                  TextButton(
                    onPressed:
                        isDeleting
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed:
                        isDeleting
                            ? null
                            : () async {
                              setState(() => isDeleting = true);

                              final ok = await controller.deleteStrategy(id);
                              if (!dialogContext.mounted) return;

                              if (ok) {
                                Navigator.of(dialogContext).pop();
                                return;
                              }

                              setState(() => isDeleting = false);
                              if (!context.mounted) return;

                              UiFeedback.showSnackBar(
                                context,
                                message: AppStrings.strategyDeleteFailed,
                                type: UiMessageType.error,
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                    ),
                    child:
                        isDeleting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                            : const Text(AppStrings.delete),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
