import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/programs/programs_controller.dart';
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
      // Generate a stable program_id from the name (lowercase, spaces → underscores)
      final programId = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');

      final response = await _api.createProgram(
        jsonDecode(jsonEncode({
          'program_id': programId,
          'name': name,
          'is_baseline': false,
          'config': <String, dynamic>{},
        })) as Map<String, dynamic>,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh ProgramsController if it's active
        try {
          Get.find<ProgramsController>().fetchPrograms();
        } catch (_) {}
        if (!mounted) return;
        UiFeedback.showSnackBar(
          context,
          message: AppStrings.programCreated,
          type: UiMessageType.success,
        );
        Navigator.of(context).pop(true);
        return;
      }
      final errMsg = (response.data is Map)
          ? (response.data['detail'] ?? response.data['message'] ?? AppStrings.programCreateFailed)
          : AppStrings.programCreateFailed;
      log('Create program failed: status=${response.statusCode} data=${response.data}');
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = errMsg.toString();
      });
      return;
    } catch (e, st) {
      log('Create program error: $e', stackTrace: st);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      return;
    }
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
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: UIConstants.spacingXXXL),
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.paddingL,
                  ),
                ),
                child:
                    _isSaving
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
