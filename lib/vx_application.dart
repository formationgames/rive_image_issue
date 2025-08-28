import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'widgets/vx_app_widget.dart';

class VxApplication {
  const VxApplication();

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    await RiveNative.init();

    runApp(VxAppWidget());
  }
}
