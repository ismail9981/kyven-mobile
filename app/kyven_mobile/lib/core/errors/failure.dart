import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.cause});

  final Object? cause;
  final String message;

  @override
  List<Object?> get props => [message, cause];
}
