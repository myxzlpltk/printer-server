import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class PrinterContentWebView extends StatefulWidget {
  const PrinterContentWebView({super.key, required this.data});

  final String data;

  @override
  State<PrinterContentWebView> createState() => _PrinterContentWebViewState();
}

class _PrinterContentWebViewState extends State<PrinterContentWebView> {
  final WebviewController _controller = WebviewController();
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _controller.initialize();
    setState(() {});
    await _controller.loadStringContent(widget.data);
    setState(() => loaded = true);
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  Future<void> scrollWebview(double mouseX, double mouseY, double dx, double dy) {
    return _controller.executeScript("""
      function eleCanScroll(ele) {
        if (ele.scrollTop > 0) { return ele; }
        else {
          ele.scrollTop++;
          const top = ele.scrollTop;
          top && (ele.scrollTop = 0);
          if(top > 0){
            return ele;
          } else {
            return eleCanScroll( ele.parentElement);
          }
        }
      }
      var el = document.elementFromPoint($mouseX,$mouseY);
      var el2 = eleCanScroll(el);
      el2.scrollBy($dx,$dy);
      """);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerPanZoomUpdate: (event) {
        final Offset panDelta = event.panDelta;
        final Offset position = event.position;
        scrollWebview(position.dx, position.dy, panDelta.dx, -panDelta.dy);
      },
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          final Offset scrollDelta = signal.scrollDelta;
          final Offset position = signal.position;
          scrollWebview(position.dx, position.dy, scrollDelta.dx, scrollDelta.dy);
        }
      },
      child: Stack(
        children: [
          Webview(
            _controller,
            permissionRequested: _onPermissionRequested,
          ),
          if (!loaded) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
