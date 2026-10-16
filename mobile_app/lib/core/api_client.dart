import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Stockage du refresh token avec repli en memoire.
///
/// `flutter_secure_storage` refuse de fonctionner sur une origine web non securisee
/// (tout `http://` qui n'est pas `localhost`). Sans ce repli, la connexion echoue
/// completement des qu'on teste l'application depuis une IP du reseau local.
class _SessionStore {
  _SessionStore(this._secure);

  final FlutterSecureStorage? _secure;
  final Map<String, String> _memoire = {};
  bool _degrade = false;

  Future<String?> read(String key) async {
    if (_degrade) return _memoire[key];
    try {
      return await _secure!.read(key: key);
    } catch (_) {
      _degrade = true;
      return _memoire[key];
    }
  }

  Future<void> write(String key, String value) async {
    _memoire[key] = value;
    if (_degrade) return;
    try {
      await _secure!.write(key: key, value: value);
    } catch (_) {
      _degrade = true;
    }
  }

  Future<void> delete(String key) async {
    _memoire.remove(key);
    if (_degrade) return;
    try {
      await _secure!.delete(key: key);
    } catch (_) {
      _degrade = true;
    }
  }
}

class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : _baseUrl = _resolveBaseUrl(baseUrl),
       _client = client ?? http.Client(),
       _store = _SessionStore(
         storage ??
             (kIsWeb
                 ? null
: const FlutterSecureStorage()),
       );

  static const _refreshKey = 'refresh_token';
  static const _configuredUrl = String.fromEnvironment('API_BASE_URL');
  static const _apiSuffix = '/api/v1';

  final String _baseUrl;
  final http.Client _client;
  final _SessionStore _store;
  String? _accessToken;
  String? _refreshToken;

  /// Racine du site (sans le suffixe `/api/v1`), pour les pages imprimables et les fichiers.
  String get siteUrl => _baseUrl.endsWith(_apiSuffix)
      ? _baseUrl.substring(0, _baseUrl.length - _apiSuffix.length)
      : _baseUrl;

  /// Access token courant, expose pour les ouvertures de page impression (query `jeton`).
  String? get accessToken => _accessToken;

  /// Adresse absolue d'un fichier servi par le backend (logo de l'entreprise).
  String assetUrl(String path) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    if (clean.isEmpty) return path;
    if (clean.startsWith('http://') || clean.startsWith('https://')) return clean;
    return '$siteUrl/${Uri.encodeComponent(clean)}';
  }

  static String _resolveBaseUrl(String? value) {
    final configured = value ?? _configuredUrl;
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }
    return kIsWeb
        ? 'http://localhost/BTP_ERP$_apiSuffix'
        : 'http://10.0.2.2/BTP_ERP$_apiSuffix';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data =
        await _send(
              'POST',
              'auth/login',
              authenticated: false,
              retryOnUnauthorized: false,
              body: {
                'email': email.trim(),
                'mot_de_passe': password,
                'client': 'mobile',
              },
            )
            as Map;
    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    if (access == null || refresh == null) {
      throw const ApiException(
        'La réponse de connexion ne contient pas les jetons.',
      );
    }
    _accessToken = access;
    _refreshToken = refresh;
    await _store.write(_refreshKey, refresh);
    return Map<String, dynamic>.from(data['utilisateur'] as Map);
  }

  Future<Map<String, dynamic>?> restoreSession() async {
    _refreshToken = await _store.read(_refreshKey);
    if (_refreshToken == null) return null;
    await _refresh();
    return Map<String, dynamic>.from(await _send('GET', 'auth/me') as Map);
  }

  Future<dynamic> getData(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> postMultipart(
    String path, {
    required String fieldName,
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/$path'))
      ..headers['Accept'] = 'application/json';
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: filename),
    );
    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 401 && _refreshToken != null) {
      await _refresh();
      return postMultipart(
        path,
        fieldName: fieldName,
        bytes: bytes,
        filename: filename,
      );
    }
    return _decode(response);
  }

  Future<void> logout() async {
    try {
      await _send(
        'POST',
        'auth/logout',
        authenticated: false,
        body: {'refresh_token': _refreshToken},
      );
    } finally {
      await clearSession();
    }
  }

  dynamic _decode(http.Response response) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Réponse API illisible (${response.statusCode}).');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map ? decoded['message'] : null;
      throw ApiException(
        message?.toString() ?? 'Erreur API (${response.statusCode}).',
      );
    }
    if (decoded is! Map || decoded['succes'] != true) {
      throw ApiException(
        decoded is Map
            ? decoded['message']?.toString() ?? 'Erreur API.'
            : 'Réponse API invalide.',
      );
    }
    return decoded['donnees'];
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    await _store.delete(_refreshKey);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retryOnUnauthorized = true,
  }) async {
    final request = http.Request(method, Uri.parse('$_baseUrl/$path'))
      ..headers['Accept'] = 'application/json'
      ..headers['Content-Type'] = 'application/json; charset=utf-8';
    if (authenticated && _accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (body != null) request.body = jsonEncode(body);

    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 401 &&
        authenticated &&
        retryOnUnauthorized &&
        _refreshToken != null) {
      await _refresh();
      return _send(
        method,
        path,
        body: body,
        authenticated: true,
        retryOnUnauthorized: false,
      );
    }

    return _decode(response);
  }

  Future<void> _refresh() async {
    final token = _refreshToken;
    if (token == null) {
      throw const ApiException('Session expirée. Reconnectez-vous.');
    }
    try {
      final data =
          await _send(
                'POST',
                'auth/refresh',
                authenticated: false,
                retryOnUnauthorized: false,
                body: {'refresh_token': token},
              )
              as Map;
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String?;
      if (access == null || refresh == null) {
        throw const ApiException('La réponse de renouvellement est invalide.');
      }
      _accessToken = access;
      _refreshToken = refresh;
      await _store.write(_refreshKey, refresh);
    } catch (_) {
      await clearSession();
      rethrow;
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}