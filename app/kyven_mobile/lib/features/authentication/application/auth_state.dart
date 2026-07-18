import 'package:equatable/equatable.dart';

import '../domain/entities/auth_user.dart';
import '../domain/entities/guest_session.dart';

enum AuthStatus { unauthenticated, loading, authenticated, guest }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.guestSession,
    this.passwordResetSent = false,
  });

  final GuestSession? guestSession;
  final bool passwordResetSent;
  final AuthStatus status;
  final AuthUser? user;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    GuestSession? guestSession,
    bool? passwordResetSent,
    bool clearUser = false,
    bool clearGuestSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      guestSession: clearGuestSession
          ? null
          : guestSession ?? this.guestSession,
      passwordResetSent: passwordResetSent ?? this.passwordResetSent,
    );
  }

  @override
  List<Object?> get props => [status, user, guestSession, passwordResetSent];
}
