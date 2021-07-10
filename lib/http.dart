import 'package:http/http.dart' as http;

import 'global.dart';

class ClientWithUserAgent extends http.BaseClient {
  final http.Client client;

  ClientWithUserAgent(this.client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] = USER_AGENT;
    return client.send(request);
  }
}
