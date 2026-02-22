import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/programs/programs_controller.dart';
import 'package:stock_app/src/features/strategies/program_create_screen.dart';
import 'package:stock_app/src/features/strategies/strategy_editor_dialog.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/widget/app_text_field.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgramsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.programs,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAll,
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: Container(
        color: AppColors.grey50,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            );
          }
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingXXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.error.value, textAlign: TextAlign.center),
                    const SizedBox(height: UIConstants.spacingL),
                    ElevatedButton(
                      onPressed: controller.fetchAll,
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          if (controller.programs.isEmpty) {
            return _buildEmpty(context, controller);
          }
          return _buildList(context, controller);
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Push create-program screen – ProgramsController is registered so
          // ProgramCreateScreen can call fetchPrograms() on it if needed.
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProgramCreateScreen()),
          );
          controller.fetchPrograms();
        },
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          AppStrings.createProgram,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ProgramsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.blue50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.layers_outlined,
                size: 50,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXXL),
            const Text(
              'No Programs Yet',
              style: TextStyle(
                fontSize: UIConstants.fontHeading,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            Text(
              AppStrings.programsScreenSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIConstants.fontL,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ProgramsController controller) {
    return RefreshIndicator(
      onRefresh: controller.fetchAll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          UIConstants.paddingL,
          UIConstants.paddingL,
          UIConstants.paddingL,
          100,
        ),
        itemCount: controller.programs.length,
        itemBuilder: (context, index) {
          final program = controller.programs[index];
          return _ProgramCard(program: program, controller: controller);
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final ProgramsController controller;

  const _ProgramCard({required this.program, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isBaseline = program['is_baseline'] == true;
    final name = (program['name'] ?? program['program_id'] ?? '').toString();
    final strategyNames = controller.strategyNamesForProgram(program);

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color:
              isBaseline
                  ? AppColors.blue.withValues(alpha: 0.4)
                  : AppColors.grey300,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: UIConstants.fontXL,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isBaseline) ...[
                            const SizedBox(width: UIConstants.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.paddingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue,
                                borderRadius: BorderRadius.circular(
                                  UIConstants.radiusS,
                                ),
                              ),
                              child: const Text(
                                AppStrings.builtIn,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingXS),
                      Text(
                        (program['program_id'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: UIConstants.fontM,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                PopupMenuButton<String>(
                  onSelected: (action) => _handleAction(context, action),
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(AppStrings.editStrategies),
                            ],
                          ),
                        ),
                        if (!isBaseline) ...[
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.drive_file_rename_outline, size: 18),
                                SizedBox(width: 8),
                                Text(AppStrings.renameProgram),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppStrings.deleteProgram,
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                  icon: const Icon(Icons.more_vert, color: AppColors.grey600),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
            const Divider(),
            const SizedBox(height: UIConstants.spacingS),
            // Strategy chips
            if (strategyNames.isEmpty)
              Text(
                AppStrings.noStrategiesInProgram,
                style: TextStyle(
                  fontSize: UIConstants.fontL,
                  color: AppColors.grey600,
                ),
              )
            else
              Wrap(
                spacing: UIConstants.spacingS,
                runSpacing: UIConstants.spacingS,
                children:
                    strategyNames
                        .map(
                          (n) => Chip(
                            label: Text(
                              n,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppColors.blue50,
                            side: BorderSide(
                              color: AppColors.blue.withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _showEditStrategiesDialog(context);
      case 'rename':
        _showRenameDialog(context);
      case 'delete':
        _showDeleteDialog(context);
    }
  }

  void _showEditStrategiesDialog(BuildContext context) {
    final currentNames = Set<String>.from(
      controller.strategyNamesForProgram(program),
    );
    final selected = RxSet<String>(currentNames);

    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(AppStrings.editStrategies),
              content: SizedBox(
              width: 340,
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        controller.allStrategies.map((strategy) {
                          final isChecked = selected.contains(strategy.name);
                          return Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (v) {
                                  if (v == true) {
                                    selected.add(strategy.name);
                                  } else {
                                    selected.remove(strategy.name);
                                  }
                                },
                              ),
                              Expanded(
                                child: Text(
                                  strategy.name,
                                  style: const TextStyle(
                                    fontSize: UIConstants.fontL,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.blue,
                                ),
                                tooltip: 'Edit rules',
                                onPressed: () => showStrategyEditorDialog(
                                  context,
                                  initial: strategy,
                                  onSubmit: (payload) =>
                                      controller.updateStrategy(
                                        strategy.id,
                                        payload,
                                      ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final ok = await controller.saveStrategyNames(
                    program,
                    selected.toList(),
                  );
                  if (!context.mounted) return;
                  UiFeedback.showSnackBar(
                    context,
                    message:
                        ok
                            ? AppStrings.programCreated
                            : AppStrings.programCreateFailed,
                    type: ok ? UiMessageType.success : UiMessageType.error,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text(AppStrings.saveStrategies),
              ),
            ],
          ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final nameCtrl = TextEditingController(
      text: (program['name'] ?? '').toString(),
    );
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(AppStrings.renameProgram),
            content: AppTextField(
              label: AppStrings.newProgramName,
              controller: nameCtrl,
              keyboardType: TextInputType.text,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  if (newName.isEmpty) return;
                  Navigator.of(dialogContext).pop();
                  final ok = await controller.renameProgram(program, newName);
                  if (!context.mounted) return;
                  UiFeedback.showSnackBar(
                    context,
                    message:
                        ok
                            ? AppStrings.programRenamed
                            : AppStrings.programRenameFailed,
                    type: ok ? UiMessageType.success : UiMessageType.error,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text(AppStrings.save),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(AppStrings.deleteProgram),
            content: const Text(AppStrings.deleteProgramWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final ok = await controller.deleteProgram(program);
                  if (!context.mounted) return;
                  UiFeedback.showSnackBar(
                    context,
                    message:
                        ok
                            ? AppStrings.programDeleted
                            : AppStrings.programDeleteFailed,
                    type: ok ? UiMessageType.success : UiMessageType.error,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text(AppStrings.delete),
              ),
            ],
          ),
    );
  }
}
