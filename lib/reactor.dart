import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'global.dart';
import 'html.dart';
import 'http.dart';
import 'page.dart';
import 'prefs.dart';

class ReactorPageView extends StatefulWidget {
  final client = HttpClientWithUserAgent(http.Client());

  final ReactorPrefs prefs;
  final Uri uri;

  ReactorPageView({
    Key? key,
    required String url,
    required String prefsPrefix,
  }) :
    prefs = ReactorPrefs(prefsPrefix),
    uri = Uri.parse(url),
    super(key: key);
  _ReactorPageViewState createState() =>
    _ReactorPageViewState(uri: uri, client: client, prefs: prefs);
}

class _ReactorPageViewState extends State<ReactorPageView> {
  final webViewKey = UniqueKey();

  late final WebViewController webView;
  late Future<ReactorPage> reactorPage;

  final Uri uri;
  final HttpClientWithUserAgent client;
  final ReactorPrefs prefs;

  _ReactorPageViewState({
    required this.uri,
    required this.client,
    required this.prefs,
  }) : super();

  Future<ReactorPage> getReactorPage(String url) async {
    return ReactorPage((await client.get(Uri.parse(url))).body);
  }

  String buildHtml(BuildContext context, ReactorPage reactorPage) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return REACTOR_HTML
      .replaceFirst(HTML_CONTENT, reactorPage.toHtml())
      .replaceFirst(HTML_CSS_COLOR, isDarkMode ? '#ddd' : 'black')
      .replaceFirst(HTML_CSS_BACKGROUND, isDarkMode ? 'black' : '#eee');
  }

  String buildUrl(BuildContext context, ReactorPage reactorPage) {
    return Uri
      .dataFromString(
        buildHtml(context, reactorPage),
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
    var url = (await reactorPage).nextPageUrl();
    if (url == null) return;
    if (!url.startsWith('/')) url = '/$url';
    await loadUrl(context, '${uri.origin}$url');
  }

  prevPageHandler(BuildContext context) async {
    var url = (await reactorPage).prevPageUrl();
    if (url == null) return;
    if (!url.startsWith('/')) url = '/$url';
    await loadUrl(context, '${uri.origin}$url');
  }

  homePageHandler(BuildContext context) async {
    await loadUrl(context, uri.origin);
  }

  onShowCommentMessage(JavascriptMessage message) async {
    final parts = message.message.split(HTML_JS_MESSAGE_SEPARATOR);
    if (parts.length != 2) return;
    final commentId = parts[0];
    var showHref = parts[1];
    if (!showHref.startsWith('/post/comment/')) return;
    final content = (await client
      .get(Uri.parse('${uri.origin}$showHref'))).body;
    webView.evaluateJavascript("""
      const comment = document.getElementById('$commentId');
      if (comment !== null) {
        comment.innerHTML = `$content`;
      }
    """);
  }

  @override
  void initState() {
    super.initState();
    reactorPage = prefs.getLastPageUrl().then((url) {
      return getReactorPage(url ?? uri.origin);
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
                  webView = controller;
                },
                javascriptChannels: Set.from([
                  JavascriptChannel(
                    name: HTML_JS_SHOW_COMMENT_CHANNEL,
                    onMessageReceived: onShowCommentMessage,
                  ),
                ]),
              );
            } else if (snapshot.hasError) {
              return Center(child: Padding(
                child: Text('Error: ${snapshot.error.toString()}'),
                padding: const EdgeInsets.all(20.0)),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(children: [
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
            ]),
          ),
        ),
      ),
    );
  }
}
