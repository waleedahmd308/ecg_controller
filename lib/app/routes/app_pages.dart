import 'package:get/get.dart';

import '../modules/SecondSample/bindings/second_sample_binding.dart';
import '../modules/SecondSample/views/second_sample_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SECOND_SAMPLE,
      page: () =>  SecondSampleView(),
      binding: SecondSampleBinding(),
    ),
  ];
}
