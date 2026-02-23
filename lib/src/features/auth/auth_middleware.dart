import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_app/src/features/auth/auth_service.dart';
import 'package:stock_app/src/utils/route/app_router.dart';

/// Intercepts every route navigation.
/// If the user is not authenticated, redirects to the login screen.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.isAuthenticated) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}
