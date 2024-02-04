import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart';
import 'package:printer_server/controllers/history_notifier.dart';
import 'package:printer_server/controllers/notification_notifier.dart';
import 'package:printer_server/controllers/server_state.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

final serverProvider = StateNotifierProvider.autoDispose<ServerNotifier, ServerState>((ref) {
  return ServerNotifier(ref);
});

class ServerNotifier extends StateNotifier<ServerState> {
  ServerNotifier(this.ref) : super(ServerState(ipAddress: InternetAddress.anyIPv4.address)) {
    _initServer();
  }

  final Ref ref;
  HttpServer? _server;

  /// Initializes the server
  Future<void> _initServer() async {
    // Create a shelf handler
    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);
    // Start the server
    _server?.close();
    _server = await shelf_io.serve(handler, state.ipAddress, state.port);
    _server?.autoCompress = true;
    log('Server started on ${_server?.address.host}:${_server?.port}');

    // Update state
    final wifiIpAddress = await NetworkInfo().getWifiIP();
    state = state.copyWith(serverStarted: true, wifiIpAddress: wifiIpAddress);
  }

  /// Handles the request
  FutureOr<Response> _handleRequest(Request request) async {
    // Send a welcome if the request is to the root
    if (request.url.path == '/') return Response.ok("Printer server is running");
    // Block requests that are not POST
    if (request.method != "POST") return Response.notFound('Not found');
    // Block requests that are not to the /printer endpoint
    if (request.url.path != 'printer') return Response.notFound('Not found');

    // Read the request body
    final binaryData = await request.read().expand((data) => data).toList();
    log("Received ${binaryData.length} bytes of data");

    // Prepare input file
    final temporaryDir = await Directory.systemTemp.createTemp("print_job_esc");
    final temporaryFile = join(temporaryDir.path, "print_job.bin");
    final file = File(temporaryFile);
    await file.writeAsBytes(binaryData);
    log("Saved to ${file.path}");

    // Compute html
    final sourceFile = join(state.enginePath, state.engineName);
    final process = await Process.run("php", [sourceFile, temporaryFile]);
    final result = process.stdout;

    // Add result
    ref.read(historyProvider.notifier).add(result);

    // Clean up
    await file.delete();

    // Return response
    return Response.ok(
      jsonEncode({
        "status": "success",
        "message": "Print job received",
        "hash": hash(file.path),
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  /// When user want to change port
  Future<void> changePort(int newPort) async {
    // Reset server
    state = state.copyWith(serverStarted: false, port: newPort);
    await _initServer();
    // Notify
    ref.read(notificationProvider.notifier).success("Server started on ${state.ipAddress}:${state.port}");
  }

  /// When user want to relocate engine
  void linkToEngine() async {
    // Open dialog file
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: dirname(join(state.enginePath, state.engineName)),
      type: FileType.custom,
      allowedExtensions: ['php'],
    );
    if (result == null) return;
    if (result.files.length != 1) return;

    // Check file valid
    final file = result.files.single;
    if (file.path == null) return showErrorInvalidEngine();
    // Check directory exists
    final dir = Directory(dirname(file.path!));
    if (!await dir.exists()) return showErrorInvalidEngine();
    // Check directory valid
    final files = await dir.list().toList();
    if (!files.any((e) => basename(e.path) == "esc2html.php")) return showErrorInvalidEngine();
    if (!files.any((e) => basename(e.path) == "esc2text.php")) return showErrorInvalidEngine();
    if (!files.any((e) => basename(e.path) == "escimages.php")) return showErrorInvalidEngine();

    // Update the engine path
    state = state.copyWith(enginePath: dirname(file.path!));

    // Notify
    ref.read(notificationProvider.notifier).success("Engine file linked to ${join(state.enginePath, state.engineName)}");
  }

  void showErrorInvalidEngine() {
    ref.read(notificationProvider.notifier).error("Invalid engine file");
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }
}
