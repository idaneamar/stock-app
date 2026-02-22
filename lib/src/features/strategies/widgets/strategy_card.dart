import 'package:flutter/material.dart';
import 'package:stock_app/src/models/strategy_response.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';

class StrategyCard extends StatelessWidget {
  final StrategyItem strategy;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StrategyCard({
    super.key,
    required this.strategy,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = strategy.enabled;

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.marginL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color:
              isEnabled
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.grey300,
          width: isEnabled ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: UIConstants.elevationXL,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(UIConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Strategy icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isEnabled
                                ? AppColors.successLight
                                : AppColors.grey100,
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        color:
                            isEnabled ? AppColors.success : AppColors.grey500,
                        size: UIConstants.iconL,
                      ),
                    ),
                    const SizedBox(width: UIConstants.spacingL),
                    // Name and id
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strategy.name,
                            style: const TextStyle(
                              fontSize: UIConstants.fontXXL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.paddingS,
                              vertical: UIConstants.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(
                                UIConstants.radiusXS,
                              ),
                            ),
                            child: Text(
                              '#${strategy.id}',
                              style: TextStyle(
                                fontSize: UIConstants.fontM,
                                color: AppColors.grey700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _buildStatusBadge(isEnabled),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: AppColors.grey200),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingM,
              vertical: UIConstants.paddingS,
            ),
            child: Row(
              children: [
                // Toggle switch with label
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: isEnabled,
                        onChanged: onToggle,
                        activeTrackColor: AppColors.success.withValues(
                          alpha: 0.5,
                        ),
                        activeThumbColor: AppColors.success,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: UIConstants.spacingS),
                      Text(
                        isEnabled ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: UIConstants.fontL,
                          color:
                              isEnabled ? AppColors.success : AppColors.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.blue,
                  tooltip: AppStrings.edit,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.blue50,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingM),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: AppStrings.delete,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.errorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: UIConstants.paddingXS + 2,
      ),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.successLight : AppColors.grey100,
        borderRadius: BorderRadius.circular(UIConstants.radiusCircular),
        border: Border.all(
          color:
              isEnabled
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.grey300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.success : AppColors.grey400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: UIConstants.spacingS),
          Text(
            isEnabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              fontSize: UIConstants.fontM,
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.green800 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
