import 'package:get/get.dart';

import '../controllers/second_sample_controller.dart';

class SecondSampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecondSampleController>(
      () => SecondSampleController(),
    );
  }
}
