import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/storage.dart';
import 'data/auth_repository.dart';
import 'data/models/user.dart';

final secureStoreProvider = Provider((_) => SecureStore());
final apiClientProvider =
Provider((ref) => ApiClient(ref.read(secureStoreProvider)));

final authRepositoryProvider = Provider(
      (ref) => AuthRepository(
    ref.read(apiClientProvider),
    ref.read(secureStoreProvider),
  ),
);

class AuthState {
  final AppUser? user;
  final bool loading;
  final String? error;
  const AuthState({this.user, this.loading = false, this.error});
  AuthState copyWith({AppUser? user, bool? loading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final u = await _repo.login(email: email, password: password);
      state = AuthState(user: u);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register(
      String email, String username, String password, String role) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.register(
        email: email,
        username: username,
        password: password,
        role: role,
      );
      // Kayıt sonrası otomatik giriş:
      final u = await _repo.login(email: email, password: password);
      state = AuthState(user: u);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
        (ref) => AuthNotifier(ref.read(authRepositoryProvider)));
