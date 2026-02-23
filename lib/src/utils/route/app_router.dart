import 'package:get/get.dart';
import 'package:stock_app/src/features/auth/auth_middleware.dart';
import 'package:stock_app/src/features/auth/login_screen.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';
import 'package:stock_app/src/features/strategies/program_create_screen.dart';

class Routes {
  static const login = '/login';
  static const home = '/home';
  static const notFound = '/404';
  static const createProgram = '/strategies/create-program';
}

final _authMiddleware = [AuthMiddleware()];

final getPages = [
  GetPage(name: Routes.login, page: () => const LoginScreen()),
  GetPage(
    name: Routes.home,
    page: () => const MainContainerScreen(),
    middlewares: _authMiddleware,
  ),
  GetPage(
    name: Routes.createProgram,
    page: () => const ProgramCreateScreen(),
    middlewares: _authMiddleware,
  ),
];
