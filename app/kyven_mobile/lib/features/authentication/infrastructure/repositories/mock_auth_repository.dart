import '../../domain/entities/auth_user.dart';
import '../../domain/entities/guest_session.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<GuestSession> continueAsGuest() async {
    return GuestSession(startedAt: DateTime.now());
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthUser(id: 'mock-registered-user', email: email, name: name);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return AuthUser(id: 'mock-signed-in-user', email: email);
  }
}
