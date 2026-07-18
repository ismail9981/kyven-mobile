import '../entities/auth_user.dart';
import '../entities/guest_session.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset({required String email});

  Future<GuestSession> continueAsGuest();
}
