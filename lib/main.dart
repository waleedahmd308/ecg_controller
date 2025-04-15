import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable DevicePreview only in development
      builder: (context) => MyApp(), // Wrap the app
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Application",
      // Use DevicePreview.appBuilder for localization and scaling
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context), // Set locale dynamically
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false, // Optional: Hide debug banner
    );
  }
}
