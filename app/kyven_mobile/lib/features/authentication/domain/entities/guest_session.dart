import 'package:equatable/equatable.dart';

class GuestSession extends Equatable {
  const GuestSession({required this.startedAt});

  final DateTime startedAt;

  @override
  List<Object> get props => [startedAt];
}
