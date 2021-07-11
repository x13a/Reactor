import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'global.dart';
import 'html.dart';
import 'http.dart';
import 'page.dart';
import 'prefs.dart';

class Reactor extends StatefulWidget {
  const Reactor({ Key? key }) : super(key: key);
  _ReactorState createState() => _ReactorState();
}

class _ReactorState extends State<Reactor> {
  late final WebViewController webView;
  late Future<ReactorPage> reactorPage;
  final prefs = Prefs();
  final client = HttpClientWithUserAgent(http.Client());
  final webViewKey = UniqueKey();

  Future<ReactorPage> getReactorPage(String url) async {
    return ReactorPage(parse((await client.get(Uri.parse(url))).body), url);
  }

  String buildHtml(bool isDarkMode, ReactorPage reactorPage) {
    return REACTOR_HTML
      .replaceFirst(HTML_CONTENT, reactorPage.toHtml())
      .replaceFirst(HTML_CSS_COLOR, isDarkMode ? '#ddd' : 'black')
      .replaceFirst(HTML_CSS_BACKGROUND, isDarkMode ? 'black' : '#eee');
  }

  String buildUrl(BuildContext context, ReactorPage reactorPage) {
    return Uri
      .dataFromString(
        buildHtml(Theme.of(context).brightness == Brightness.dark, reactorPage),
        mimeType: 'text/html',
        encoding: Utf8Codec(),
        base64: true,
      ).toString();
  }

  Future<bool> onWillPop(BuildContext context) async {
    if (await webView.canGoBack()) {
      webView.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }

  loadUrl(BuildContext context, String url) async {
    prefs.setLastPageUrl(url);
    final page = await getReactorPage(url);
    webView.loadUrl(buildUrl(context, page));
    reactorPage = Future.value(page);
  }

  nextPageHandler(BuildContext context) async {
    final url = (await reactorPage).nextPageUrl();
    if (url == null) return;
    await loadUrl(context, url);
  }

  prevPageHandler(BuildContext context) async {
    final url = (await reactorPage).prevPageUrl();
    if (url == null) return;
    await loadUrl(context, url);
  }

  homePageHandler(BuildContext context) async {
    await loadUrl(context, JOYREACTOR_URL);
  }

  @override
  void initState() {
    super.initState();
    reactorPage = prefs.getLastPageUrl().then((url) {
      return getReactorPage(url ?? JOYREACTOR_URL);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: Scaffold(
        body: SafeArea(child: FutureBuilder(
          future: reactorPage,
          builder: (BuildContext context, AsyncSnapshot<ReactorPage> snapshot) {
            if (snapshot.hasData) {
              return WebView(
                key: webViewKey,
                initialUrl: buildUrl(context, snapshot.data!),
                javascriptMode: JavascriptMode.unrestricted,
                userAgent: USER_AGENT,
                onWebViewCreated: (WebViewController controller) {
                  this.webView = controller;
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => prevPageHandler(context),
                  icon: const Icon(Icons.arrow_left)),
                const Spacer(),
                IconButton(
                  onPressed: () => homePageHandler(context),
                  icon: const Icon(Icons.home)),
                const Spacer(),
                IconButton(
                  onPressed: () => nextPageHandler(context),
                  icon: const Icon(Icons.arrow_right)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
