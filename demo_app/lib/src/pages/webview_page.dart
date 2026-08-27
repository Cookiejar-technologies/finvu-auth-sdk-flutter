import 'package:finvu_authentication_sdk/finvu_authentication_sdk.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String? customUrl;

  const WebViewPage({super.key, this.customUrl});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  late final IFinvuWebViewWrapper _wrapper;
  bool _ready = false;
  final List<String> _logs = [];

  static const _defaultWebUrl =
      'https://test-web-app-8a50c.web.app/?v=debug-1';

  static const String _consoleCaptureScript = '''
(function() {
  if (window.__finvuConsoleHook) return;
  window.__finvuConsoleHook = true;
  var levels = ['log', 'info', 'warn', 'error', 'debug'];
  levels.forEach(function(level) {
    var original = console[level];
    console[level] = function() {
      try {
        var args = Array.prototype.slice.call(arguments);
        var formatted = args.map(function(a) {
          if (a instanceof Error) return a.stack || a.message;
          if (typeof a === 'object') {
            try { return JSON.stringify(a); } catch (e) { return String(a); }
          }
          return String(a);
        }).join(' ');
        FinvuConsoleLogger.postMessage('[' + level.toUpperCase() + '] ' + formatted);
      } catch (e) {}
      return original.apply(console, arguments);
    };
  });
  window.addEventListener('error', function(e) {
    try {
      FinvuConsoleLogger.postMessage('[ERROR] ' + (e.message || 'Unknown error'));
    } catch (err) {}
  });
})();
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FinvuConsoleLogger',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            setState(() => _logs.add(message.message));
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _controller.runJavaScript(_consoleCaptureScript);
          },
        ),
      );
    _wrapper = FinvuAuthSdk.webViewBridge();
    _init();
  }

  Future<void> _init() async {
    await _wrapper.setupWebView(
      env: Environment.development,
      controller: _controller,
    );
    final String urlToLoad = widget.customUrl?.isNotEmpty == true
        ? widget.customUrl!
        : _defaultWebUrl;
    await _controller.loadRequest(Uri.parse(urlToLoad));
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _wrapper.cleanupAll();
    super.dispose();
  }

  void _showLogs() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'JS Console (${_logs.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _logs.clear());
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No logs yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: _logs.length,
                            itemBuilder: (_, i) => SelectableText(
                              _logs[i],
                              style: const TextStyle(
                                color: Color(0xFF00FF66),
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finvu Auth SDK Demo App',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          if (_ready)
            WebViewWidget(controller: _controller)
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _showLogs,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'JS Logs (${_logs.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
