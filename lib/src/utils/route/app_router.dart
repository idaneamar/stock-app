import 'package:get/get.dart';
import 'package:stock_app/src/features/main_container/main_container_screen.dart';

class Routes {
  static const home = '/home';
  static const notFound = '/404';
}

final getPages = [
  GetPage(name: Routes.home, page: () => const MainContainerScreen()),
];
