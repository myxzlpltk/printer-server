import 'package:flutter/material.dart';
import 'package:printer_server/app.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // For full-screen example
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(const MyApp());
}