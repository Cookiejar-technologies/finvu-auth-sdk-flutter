import 'package:demo_app/src/pages/native_view_page.dart';
import 'package:demo_app/src/pages/webview_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FinvuDemoApp());
}

class FinvuDemoApp extends StatelessWidget {
  const FinvuDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finvu Auth SDK Demo App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _defaultUrl = 'https://test-web-app-8a50c.web.app';
  final TextEditingController _urlController = TextEditingController(
    text: _defaultUrl,
  );
  String _customUrl = _defaultUrl;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(() {
      setState(() => _customUrl = _urlController.text.trim());
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUrlEmpty = _customUrl.isEmpty;

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'WebView URL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Enter custom URL for webview',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.url,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isUrlEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WebViewPage(customUrl: _customUrl),
                                  ),
                                );
                              },
                        child: const Text('Load WebView'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NativeViewPage(),
                            ),
                          );
                        },
                        child: const Text('Load Native View'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
