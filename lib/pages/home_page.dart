import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printer_server/controllers/history_notifier.dart';
import 'package:printer_server/controllers/server_notifier.dart';
import 'package:printer_server/shared/notification_scope.dart';
import 'package:printer_server/widgets/printer_content_web_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationScope(
        child: Consumer(
          builder: (context, ref, child) {
            final serverStarted = ref.watch(serverProvider.select((value) => value.serverStarted));
            final htmlData = ref.watch(historyProvider.select((value) => value.htmlData));
            final lastPrinted = ref.watch(historyProvider.select((value) => value.lastPrinted));

            if (!serverStarted) {
              return const Center(child: CircularProgressIndicator());
            } else if (htmlData != null) {
              return Stack(
                children: [
                  PrinterContentWebView(
                    key: ValueKey(lastPrinted),
                    data: htmlData,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Last printed: $lastPrinted',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
              );
            } else {
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
          },
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              final state = _key.currentState;
              if (state != null) state.toggle();
              showQRCode(context);
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('Show QR code'),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              ref.read(serverProvider.notifier).linkToEngine();
              final state = _key.currentState;
              if (state != null) state.toggle();
            },
            icon: const Icon(Icons.link),
            label: const Text('Link to engine'),
          ),
          FloatingActionButton(
            onPressed: () => ref.read(historyProvider.notifier).toggleNotify(),
            child: Consumer(
              builder: (context, ref, child) {
                final notify = ref.watch(historyProvider.select((value) => value.notify));
                return Icon(notify ? Icons.notifications_active : Icons.notifications_off);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the QR code
  void showQRCode(BuildContext context) async {
    // Show the dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan the QR code', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 200,
              child: Consumer(
                builder: (context, ref, child) {
                  final url = ref.watch(serverProvider.select((value) => "${value.wifiIpAddress}:${value.port}"));
                  return QrImageView(data: url, size: 200);
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final wifiIpAddress = ref.watch(serverProvider.select((value) => value.wifiIpAddress));
                return TextFormField(
                  initialValue: wifiIpAddress,
                  decoration: const InputDecoration(labelText: 'IP Address'),
                  readOnly: true,
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final port = ref.watch(serverProvider.select((value) => value.port));
                return TextFormField(
                  initialValue: port.toString(),
                  decoration: const InputDecoration(labelText: 'Port'),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (value) {
                    ref.read(serverProvider.notifier).changePort(int.parse(value));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
