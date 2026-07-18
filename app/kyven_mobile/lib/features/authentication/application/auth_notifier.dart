import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/auth_repository.dart';
import '../infrastructure/repositories/mock_auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const MockAuthRepository(),
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AuthState();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      passwordResetSent: false,
      clearGuestSession: true,
    );
    final user = await _repository.signIn(email: email, password: password);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearGuestSession: true,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      passwordResetSent: false,
      clearGuestSession: true,
    );
    final user = await _repository.register(
      name: name,
      email: email,
      password: password,
    );
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearGuestSession: true,
    );
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      passwordResetSent: false,
    );
    await _repository.sendPasswordReset(email: email);
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      passwordResetSent: true,
    );
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      passwordResetSent: false,
      clearUser: true,
    );
    final guestSession = await _repository.continueAsGuest();
    state = state.copyWith(
      status: AuthStatus.guest,
      guestSession: guestSession,
      clearUser: true,
    );
  }
}
