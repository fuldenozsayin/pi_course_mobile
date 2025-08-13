import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/storage.dart';
import 'models/user.dart';

/// Tüm auth işlemlerinin tek kapısı.
/// İMZA (sabit):
/// - login({email, password}) -> Future<AppUser>
/// - register({email, username, password, role}) -> Future<void>
/// - logout() -> Future<void>
/// - meRaw() -> Future<Map<String,dynamic>>
/// - me() -> Future<AppUser>
/// - updateMe(Map) -> Future<void>
class AuthRepository {
  final Dio _dio;
  final SecureStore _store;

  AuthRepository(ApiClient api, this._store) : _dio = api.dio;

  Future<AppUser> login({required String email, required String password}) async {
    final r = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    // Beklenen response: { access: '...', refresh: '...', user: {...} }
    final data = r.data as Map;
    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    final userMap = (data['user'] as Map?)?.cast<String, dynamic>();

    if (access != null) await _store.write('access_token', access);
    if (refresh != null) await _store.write('refresh_token', refresh);

    if (userMap != null) return AppUser.fromJson(userMap);
    // Eğer backend user döndürmüyorsa, /me çek
    final meMap = await meRaw();
    return AppUser.fromJson(meMap);
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String role, // 'student' | 'tutor'
  }) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
      'role': role,
    });
  }

  Future<void> logout() async {
    // Backend revoke varsa çağır:
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // sessiz geç
    }
    await _store.delete('access_token');
    await _store.delete('refresh_token');
  }

  Future<Map<String, dynamic>> meRaw() async {
    final r = await _dio.get('/me');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<AppUser> me() async {
    final m = await meRaw();
    return AppUser.fromJson(m);
  }

  Future<void> updateMe(Map<String, dynamic> payload) async {
    try {
      await _dio.patch('/me', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        String msg = 'Geçersiz veri';
        if (data is Map) {
          final parts = <String>[];
          data.forEach((k, v) {
            if (v is List) {
              parts.add('$k: ${v.join(', ')}');
            } else {
              parts.add('$k: $v');
            }
          });
          if (parts.isNotEmpty) msg = parts.join('\n');
        }
        throw Exception(msg);
      }
      rethrow;
    }
  }
}
