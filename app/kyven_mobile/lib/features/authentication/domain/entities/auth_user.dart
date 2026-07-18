import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.email, this.name});

  final String email;
  final String id;
  final String? name;

  @override
  List<Object?> get props => [id, email, name];
}
