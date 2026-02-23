import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/auth/auth_service.dart';
import 'package:stock_app/src/utils/colors/app_colors.dart';
import 'package:stock_app/src/utils/constants/ui_constants.dart';
import 'package:stock_app/src/utils/route/app_router.dart';

// ── Change this to your desired password ─────────────────────────────────────
const String kAppPassword = 'StockApp2024';
// ─────────────────────────────────────────────────────────────────────────────

const Color _bg = Color(0xFF1A1F36);
const Color _accent = Color(0xFF4F78FF);
const Color _card = Color(0xFF242A45);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _error = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _controller.text;
    if (input == kAppPassword) {
      setState(() => _loading = true);
      AuthService.login();
      Get.offAllNamed(Routes.home);
    } else {
      setState(() {
        _error = true;
        _loading = false;
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingXXL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(UIConstants.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(UIConstants.radiusL),
                    ),
                    child: const Icon(
                      Icons.candlestick_chart_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXXXL),
                  const Text(
                    'StockApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: UIConstants.fontHeading,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  Text(
                    'Enter your password to continue',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: UIConstants.fontL,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Password field
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                        borderSide: const BorderSide(color: _accent, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          UIConstants.radiusM,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                      errorText:
                          _error ? 'Incorrect password. Try again.' : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onChanged: (_) {
                      if (_error) setState(() => _error = false);
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingXXXL),

                  // Enter button
                  SizedBox(
                    width: double.infinity,
                    height: UIConstants.buttonHeightL,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusM,
                          ),
                        ),
                      ),
                      child:
                          _loading
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Enter',
                                style: TextStyle(
                                  fontSize: UIConstants.fontXL,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
