// lib/core/storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Güvenli depolama sarmalayıcısı
/// ApiClient ve AuthRepository'nin beklediği yardımcı metotları içerir.
class SecureStore {
  static const FlutterSecureStorage _s = FlutterSecureStorage();

  static const String _kAccess = 'access_token';
  static const String _kRefresh = 'refresh_token';

  // ---- Düşük seviyeli (generic) API ----
  Future<void> write(String key, String value) => _s.write(key: key, value: value);
  Future<String?> read(String key) => _s.read(key: key);
  Future<void> delete(String key) => _s.delete(key: key);
  Future<void> deleteAll() => _s.deleteAll();

  // ---- Yüksek seviyeli yardımcılar (ApiClient'in kullandıkları) ----
  Future<void> saveTokens(String access, String refresh) async {
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _s.read(key: _kAccess);
  Future<String?> readRefresh() => _s.read(key: _kRefresh);

  Future<void> clear() => _s.deleteAll();
}
