import 'dart:async';
import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  GoogleAuthClient(this._headers, [http.Client? client])
      : _client = client ?? http.Client();

  final Map<String, String> _headers;
  final http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
