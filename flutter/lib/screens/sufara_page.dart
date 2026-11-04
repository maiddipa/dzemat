import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SufaraPage extends StatefulWidget {
  const SufaraPage({super.key});

  @override
  State<SufaraPage> createState() => _SufaraPageState();
}

class _SufaraPageState extends State<SufaraPage> {
  static const String _lessonsUrl =
      'https://sufara.ba/lekcije';

  late final WebViewController _controller;

  int _progress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        const Color(0xFFF4F7F5),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;

            setState(() {
              _progress = progress;
            });
          },

          onPageStarted: (String url) {
            if (!mounted) return;

            setState(() {
              _hasError = false;
              _errorMessage = '';
              _progress = 0;
            });
          },

          onPageFinished: (String url) {
            if (!mounted) return;

            setState(() {
              _progress = 100;
            });
          },

          onWebResourceError: (
            WebResourceError error,
          ) {
            /*
             * Ignoriši greške reklama, slika i drugih
             * elemenata koji nisu glavna stranica.
             */
            if (error.isForMainFrame == false) {
              return;
            }

            if (!mounted) return;

            setState(() {
              _hasError = true;
              _errorMessage =
                  'Lekcije se nisu mogle učitati.\n'
                  '${error.description}';
            });
          },

          onNavigationRequest: (
            NavigationRequest request,
          ) {
            final Uri? uri = Uri.tryParse(
              request.url,
            );

            if (uri == null) {
              return NavigationDecision.prevent;
            }

            const Set<String> allowedHosts = {
              'sufara.ba',
              'www.sufara.ba',
              'youtube.com',
              'www.youtube.com',
              'm.youtube.com',
              'youtu.be',
              'youtube-nocookie.com',
              'www.youtube-nocookie.com',
            };

            if (allowedHosts.contains(uri.host)) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(_lessonsUrl),
      );
  }

  Future<void> _reload() async {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
        _progress = 0;
      });
    }

    await _controller.loadRequest(
      Uri.parse(
        '$_lessonsUrl?refresh='
        '${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  Future<void> _openLessonsHome() async {
    await _controller.loadRequest(
      Uri.parse(_lessonsUrl),
    );
  }

  Future<void> _goBack() async {
    final bool canGoBack =
        await _controller.canGoBack();

    if (canGoBack) {
      await _controller.goBack();
      return;
    }

    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _goForward() async {
    final bool canGoForward =
        await _controller.canGoForward();

    if (canGoForward) {
      await _controller.goForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        _progress < 100 && !_hasError;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        bool didPop,
        Object? result,
      ) async {
        if (didPop) return;

        await _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sufara'),
          backgroundColor:
              const Color(0xFF176B4D),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Početna stranica lekcija',
              onPressed: _openLessonsHome,
              icon: const Icon(
                Icons.home_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Osvježi',
              onPressed: _reload,
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
          bottom: isLoading
              ? PreferredSize(
                  preferredSize:
                      const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _progress == 0
                        ? null
                        : _progress / 100,
                    minHeight: 3,
                    backgroundColor:
                        Colors.white24,
                    color: const Color(
                      0xFFD7B56D,
                    ),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: _hasError
              ? _buildError()
              : WebViewWidget(
                  controller: _controller,
                ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Nazad',
                  onPressed: _goBack,
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),
                IconButton(
                  tooltip: 'Naprijed',
                  onPressed: _goForward,
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                ),
                IconButton(
                  tooltip: 'Osvježi',
                  onPressed: _reload,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: Color(0xFF176B4D),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sufara nije dostupna',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _reload,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Pokušaj ponovo',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF176B4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}