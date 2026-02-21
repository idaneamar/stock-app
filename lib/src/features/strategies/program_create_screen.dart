import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/strategies/strategies_controller.dart';
import 'package:stock_app/src/utils/app_strings/dart/app_strings.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/handlers/ui_feedback.dart';
import 'package:stock_app/src/utils/services/api_service.dart';
import 'package:stock_app/src/utils/widget/app_text_field.dart';

class ProgramCreateScreen extends StatefulWidget {
  const ProgramCreateScreen({super.key});

  @override
  State<ProgramCreateScreen> createState() => _ProgramCreateScreenState();
}

class _ProgramCreateScreenState extends State<ProgramCreateScreen> {
  final StrategiesController controller = Get.find<StrategiesController>();
  final ApiService _api = ApiService();
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = AppStrings.programNameRequired);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    try {
      final response = await _api.createProgram({
        'name': name,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await controller.fetchPrograms();
        if (!mounted) return;
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.programCreated,
          type: UiMessageType.success,
        );
        Navigator.of(context).pop(true);
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _errorMessage = AppStrings.programCreateFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.createProgram,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Container(
        color: AppColors.grey50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(UIConstants.paddingM),
                  margin: const EdgeInsets.only(bottom: UIConstants.spacingL),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
              AppTextField(
                label: AppStrings.programName,
                controller: _nameController,
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingL),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(AppStrings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
