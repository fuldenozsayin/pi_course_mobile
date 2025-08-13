import '../../../core/api_client.dart';
import '../../../core/storage.dart';
import 'models/auth_tokens.dart';
import 'models/user.dart';

class AuthRepository {
  final ApiClient _api;
  final SecureStore _store;
  AuthRepository(this._api, this._store);

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    await _api.dio.post('/auth/register', data: {
      'email': email, 'username': username, 'password': password, 'role': role,
    });
  }

  Future<AppUser> me() async {
    final r = await _api.dio.get('/me');
    return AppUser.fromJson(r.data as Map<String, dynamic>);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final r = await _api.dio.post('/auth/login', data: {
      'email': email, 'password': password,
    });
    final tokens = AuthTokens.fromJson(r.data as Map<String, dynamic>);
    await _store.saveTokens(tokens.access, tokens.refresh);
    return me();
  }

  Future<void> logout() async => _store.clear();

  Future<Map<String, dynamic>> meRaw() async {
    final r = await _api.dio.get('/me');
    return r.data as Map<String, dynamic>;
  }

  Future<void> updateMe(Map<String, dynamic> patch) async {
    await _api.dio.patch('/me', data: patch);
  }

}
