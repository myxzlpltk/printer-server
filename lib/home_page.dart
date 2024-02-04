import 'package:flutter/material.dart';
import 'package:printer_server/controller.dart';
import 'package:printer_server/printer_content_web_view.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final serverStarted = context.select<MyAppController, bool>((model) => model.serverStarted);

          if (serverStarted) {
            final result = context.select<MyAppController, String?>((model) => model.result);
            final lastPrinted = context.select<MyAppController, DateTime?>((model) => model.lastPrinted);

            if (result == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.print, size: 100, color: Colors.grey.shade800),
                    const SizedBox(height: 16),
                    Text(
                      'You have not printed anything yet',
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return PrinterContentWebView(key: ValueKey(lastPrinted), data: result);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showQRCode(context),
        icon: const Icon(Icons.qr_code),
        label: const Text('Show QR code'),
      ),
    );
  }

  /// Shows the QR code
  void showQRCode(BuildContext context) async {
    // Show the dialog
    await showDialog(
      context: context,
      builder: (context) {
        final ipAddress = context.select<MyAppController, String>((model) => model.ipAddress);
        final port = context.select<MyAppController, int>((model) => model.port);
        final url = 'http://$ipAddress:$port';

        return AlertDialog(
          title: const Text('Scan the QR code', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: 200, child: QrImageView(data: url, size: 200)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: ipAddress,
                decoration: const InputDecoration(labelText: 'IP Address'),
                readOnly: true,
              ),
              TextFormField(
                initialValue: port.toString(),
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (value) async {
                  // Change the port
                  await context.read<MyAppController>().changePort(int.parse(value));
                  // Show a snack bar
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  final snackBar = SnackBar(content: Text('Port changed to $value'), behavior: SnackBarBehavior.floating, width: 200);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Link to the engine
                final engineName = await context.read<MyAppController>().linkToEngine();
                // Show a snack bar
                if (!context.mounted) return;
                if (engineName == null) {
                  const snackBar = SnackBar(content: Text('Engine not linked'), behavior: SnackBarBehavior.floating, width: 200);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  Navigator.pop(context);
                  final snackBar = SnackBar(content: Text('Engine linked to $engineName'), behavior: SnackBarBehavior.floating, width: 400);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text('Link to engine'),
            ),
          ],
        );
      },
    );
  }
}
