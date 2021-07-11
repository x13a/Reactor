import 'package:http/http.dart' as http;

import 'global.dart';

class HttpClientWithUserAgent extends http.BaseClient {
  final http.Client client;

  HttpClientWithUserAgent(this.client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] = USER_AGENT;
    return client.send(request);
  }
}
