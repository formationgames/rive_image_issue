import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'vx_app_widget.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RiveNative.init();

  runApp(SingleChildScrollView(child: VxAppWidget()));
}
