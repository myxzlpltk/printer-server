import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';

class PrinterContent extends StatelessWidget {
  const PrinterContent({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Html(
        data: data,
        shrinkWrap: true,
      ),
    );
  }
}
