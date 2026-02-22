import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/settings/settings_controller.dart';
import 'package:stock_app/src/features/main_container/main_container_controller.dart';
import 'package:stock_app/src/utils/formatters/number_format.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/widget/common/common_widgets.dart';
import 'package:stock_app/src/utils/widget/app_text_field.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(
    SettingsController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(color: AppColors.grey50, child: _buildBody(context)),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        AppStrings.settings,
        style: const TextStyle(color: AppColors.white),
      ),
      centerTitle: true,
      backgroundColor: AppColors.black,
      iconTheme: const IconThemeData(color: AppColors.white),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.white),
        onPressed: () => Get.find<MainContainerController>().openDrawer(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return LoadingWidget(
          message: AppStrings.loadingSettings,
          color: AppColors.black,
        );
      }
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }
      if (controller.error.value.isNotEmpty) {
        return ErrorStateWidget(
          errorMessage: controller.error.value,
          onRetry: controller.refreshSettings,
        );
      }
      if (controller.settings.value == null) {
        return _buildNoSettingsFound();
      }
      return _buildSettingsContent(context);
    });
  }

  Widget _buildNoSettingsFound() {
    return EmptyStateWidget(
      title: AppStrings.noSettingsFound,
      subtitle: AppStrings.unableToLoadSettings,
      icon: Icons.settings,
      onRetry: controller.refreshSettings,
      retryButtonText: AppStrings.refresh,
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshSettings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.spacingXXXL),
            _buildSettingsCard(),
            const SizedBox(height: UIConstants.spacingL),
            _buildEditButton(context),
            const SizedBox(height: UIConstants.spacingXL),
            _buildEngineSettingsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.settings,
              color: AppColors.blue,
              size: UIConstants.iconXL,
            ),
            const SizedBox(width: UIConstants.spacingL),
            Text(
              AppStrings.appSettings,
              style: const TextStyle(
                fontSize: UIConstants.fontHeading,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingM),
        Text(
          AppStrings.managePreferences,
          style: TextStyle(
            fontSize: UIConstants.fontL,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: AppPadding.allXL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: UIConstants.elevationXL,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final portfolioSize =
            controller.settings.value?.portfolioSize ?? 350000;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.portfolioSize,
                  style: TextStyle(
                    fontSize: UIConstants.fontXL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingS),
                Text(
                  formatUsd(portfolioSize, fractionDigits: 0),
                  style: const TextStyle(
                    fontSize: UIConstants.fontHeading,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            if (controller.isUpdating.value) const LoadingIndicator(),
          ],
        );
      }),
    );
  }

  Widget _buildEngineSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allXL,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: UIConstants.elevationXL,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.blue, size: 22),
              const SizedBox(width: UIConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.engineSettings,
                      style: TextStyle(
                        fontSize: UIConstants.fontXL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.engineSettingsSubtitle,
                      style: TextStyle(fontSize: 12, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingL),
          const Divider(),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.useVixFilter),
              subtitle: Text(
                AppStrings.useVixFilterHint,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              value: controller.useVixFilter.value,
              onChanged: controller.setUseVixFilter,
            ),
          ),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.strictRules),
              subtitle: Text(
                AppStrings.strictRulesHint,
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
              value: controller.strictRules.value,
              onChanged: (v) => controller.strictRules.value = v,
            ),
          ),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.volumeSpikeRequired),
              value: controller.volumeSpikeRequired.value,
              onChanged: (v) => controller.volumeSpikeRequired.value = v,
            ),
          ),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.allowIntradayPrices),
              value: controller.useIntraday.value,
              onChanged: (v) => controller.useIntraday.value = v,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          AppTextField(
            label: AppStrings.adxMin,
            controller: controller.adxMinCtrl,
            isDecimal: true,
          ),
          const SizedBox(height: UIConstants.spacingM),
          AppTextField(
            label: AppStrings.dailyLossLimitPct,
            controller: controller.dailyLossLimitCtrl,
            isDecimal: true,
          ),
          const SizedBox(height: UIConstants.spacingL),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    controller.isUpdating.value
                        ? null
                        : () => controller.saveEngineSettings(context),
                icon: const Icon(Icons.save, color: AppColors.white),
                label: Text(
                  controller.isUpdating.value
                      ? AppStrings.updatingSettings
                      : AppStrings.saveEngineSettings,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: UIConstants.fontL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      controller.isUpdating.value
                          ? AppColors.grey300
                          : AppColors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.paddingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed:
              controller.isUpdating.value
                  ? null
                  : () => controller.showEditDialog(context),
          icon: Icon(
            Icons.edit,
            color:
                controller.isUpdating.value ? AppColors.grey : AppColors.white,
          ),
          label: Text(
            controller.isUpdating.value
                ? AppStrings.updatingSettings
                : AppStrings.editSettings,
            style: TextStyle(
              color:
                  controller.isUpdating.value
                      ? AppColors.grey
                      : AppColors.white,
              fontSize: UIConstants.fontXL,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                controller.isUpdating.value
                    ? AppColors.grey300
                    : AppColors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingXXL,
              vertical: UIConstants.paddingL,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
          ),
        ),
      ),
    );
  }
}
