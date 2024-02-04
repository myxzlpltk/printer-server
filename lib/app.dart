import 'package:flutter/material.dart';
import 'package:printer_server/controller.dart';
import 'package:printer_server/home_page.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppController(),
      child: MaterialApp(
        title: 'Printer Server',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}
