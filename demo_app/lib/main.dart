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
      title: 'Finvu Auth SDK Demo',
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
  final TextEditingController _urlController = TextEditingController();
  String _customUrl = 'https://test-web-app-8a50c.web.app';

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://test-web-app-8a50c.web.app';
    _customUrl = _urlController.text.trim();
    _urlController.addListener(() {
      setState(() {
        _customUrl = _urlController.text.trim();
      });
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

    print(
      'Building HomePage - isUrlEmpty: $isUrlEmpty, customUrl: $_customUrl',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Finvu Auth — Demo'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose a flow',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // URL Input
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Custom URL',
                        hintText: 'Enter custom URL for webview',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.link),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[50],
                      ),
                      keyboardType: TextInputType.url,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isUrlEmpty
                            ? null
                            : () {
                                print(
                                  'Navigating to WebView with URL: $_customUrl',
                                );
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
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: isUrlEmpty
                            ? null
                            : () {
                                print(
                                  'Navigating to NativeView with URL: $_customUrl',
                                );
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
