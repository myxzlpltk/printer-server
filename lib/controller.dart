import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:flutter/material.dart';

class MyAppController extends ChangeNotifier {
  MyAppController() {
    _initServer();
  }

  // Private fields
  HttpServer? _server;
  final _ipAddress = InternetAddress.loopbackIPv4;
  int _port = 8080;
  final String _engineName = "esc2html.php";
  String _enginePath = "D:\\Github\\escpos-tools";

  // Public fields
  String get ipAddress => _ipAddress.address;

  int get port => _port;

  // State
  bool serverStarted = false;
  String? result;
  DateTime? lastPrinted;

  /// Adds a result to the list
  void addResult(String result) {
    this.result = result;
    lastPrinted = DateTime.now();
    notifyListeners();
  }

  /// Initializes the server
  Future<void> _initServer() async {
    // Create a shelf handler
    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handleRequest);
    // Start the server
    _server?.close();
    _server = await shelf_io.serve(handler, _ipAddress, _port);
    _server?.autoCompress = true;
    log('Server started on $_ipAddress:$_port');

    // Update state
    serverStarted = true;
    notifyListeners();
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
    final sourceFile = join(_enginePath, _engineName);
    final process = await Process.run("php", [sourceFile, temporaryFile]);
    final result = process.stdout;

    // Add result
    addResult(result);

    // Clean up
    await file.delete();

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
    serverStarted = false;
    notifyListeners();

    // Update the port and server
    _port = newPort;
    await _initServer();
  }

  /// When user want to relocate engine
  Future<String?> linkToEngine() async {
    // Open dialog file
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: dirname(join(_enginePath, _engineName)),
      type: FileType.custom,
      allowedExtensions: ['php'],
    );
    if (result == null) return null;
    if (result.files.length != 1) return null;

    // Check file valid
    final file = result.files.single;
    if (file.path == null) return null;
    // Check directory exists
    final dir = Directory(dirname(file.path!));
    if (!await dir.exists()) return null;
    // Check directory valid
    final files = await dir.list().toList();
    if (!files.any((e) => basename(e.path) == "esc2html.php")) return null;
    if (!files.any((e) => basename(e.path) == "esc2text.php")) return null;
    if (!files.any((e) => basename(e.path) == "escimages.php")) return null;

    // Update the engine path
    _enginePath = dirname(file.path!);

    return join(_enginePath, _engineName);
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }
}
