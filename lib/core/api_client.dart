import 'package:dio/dio.dart';
import 'env.dart';
import 'storage.dart';

class ApiClient {
  final Dio dio;
  final SecureStore _store;

  ApiClient(this._store)
      : dio = Dio(BaseOptions(
    baseUrl: '${Env.apiBaseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json',},
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await _store.readAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final ok = await _tryRefreshToken();
          if (ok) {
            final req = e.requestOptions;
            final newResp = await dio.fetch(req
              ..headers['Authorization'] = 'Bearer ${await _store.readAccess()}');
            return handler.resolve(newResp);
          }
        }
        handler.next(e);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await _store.readRefresh();
    if (refresh == null) return false;
    try {
      final r = await dio.post('/auth/refresh', data: {'refresh': refresh});
      final access = r.data['access'] as String?;
      if (access == null) return false;
      await _store.saveTokens(access, refresh);
      return true;
    } catch (_) {
      await _store.clear();
      return false;
    }
  }
}
