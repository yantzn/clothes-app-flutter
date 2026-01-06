import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    _logRequest('POST', uri, headers, body);
    return _client
        .post(uri, headers: headers, body: body)
        .then((res) {
          _logResponse('POST', uri, res);
          return res;
        })
        .catchError((error) {
          _logError('POST', uri, error);
          throw error;
        });
  }

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    _logRequest('GET', uri, headers, null);
    return _client
        .get(uri, headers: headers)
        .then((res) {
          _logResponse('GET', uri, res);
          return res;
        })
        .catchError((error) {
          _logError('GET', uri, error);
          throw error;
        });
  }

  Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    _logRequest('PUT', uri, headers, body);
    return _client
        .put(uri, headers: headers, body: body)
        .then((res) {
          _logResponse('PUT', uri, res);
          return res;
        })
        .catchError((error) {
          _logError('PUT', uri, error);
          throw error;
        });
  }

  Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    _logRequest('PATCH', uri, headers, body);
    return _client
        .patch(uri, headers: headers, body: body)
        .then((res) {
          _logResponse('PATCH', uri, res);
          return res;
        })
        .catchError((error) {
          _logError('PATCH', uri, error);
          throw error;
        });
  }

  /// 環境変数のベースURLからパスを解決して `Uri` を生成します。
  Uri resolve(String path) {
    final base = AppConfig.apiBaseUrl;
    if (path.startsWith('/')) {
      return Uri.parse('$base$path');
    }
    return Uri.parse('$base/$path');
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String>? headers,
    Object? body,
  ) {
    if (!kDebugMode) return;
    final bodyPreview = _previewBody(body);
    debugPrint('[ApiClient] => $method ${uri.toString()}');
    if (headers != null) debugPrint('[ApiClient] headers: $headers');
    if (bodyPreview != null) debugPrint('[ApiClient] body: $bodyPreview');
  }

  void _logResponse(String method, Uri uri, http.Response res) {
    if (!kDebugMode) return;
    final bodyPreview = res.body.length > 800
        ? '${res.body.substring(0, 800)}...(${res.body.length} bytes)'
        : res.body;
    debugPrint('[ApiClient] <= $method ${uri.toString()} [${res.statusCode}]');
    debugPrint('[ApiClient] response: $bodyPreview');
  }

  void _logError(String method, Uri uri, Object error) {
    if (!kDebugMode) return;
    debugPrint('[ApiClient] !! $method ${uri.toString()} error: $error');
  }

  String? _previewBody(Object? body) {
    if (body == null) return null;
    final s = body.toString();
    if (s.length <= 800) return s;
    return '${s.substring(0, 800)}...(${s.length} bytes)';
  }

  void dispose() {
    _client.close();
  }
}
