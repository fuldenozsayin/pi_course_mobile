import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _kAccess = 'access';
  static const _kRefresh = 'refresh';
  final _ss = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await _ss.write(key: _kAccess, value: access);
    await _ss.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _ss.read(key: _kAccess);
  Future<String?> readRefresh() => _ss.read(key: _kRefresh);
  Future<void> clear() => _ss.deleteAll();
}
