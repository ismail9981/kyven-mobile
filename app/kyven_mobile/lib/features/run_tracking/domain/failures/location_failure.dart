import '../../../../core/errors/failure.dart';

enum LocationFailureType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unavailable,
}

class LocationFailure extends Failure {
  const LocationFailure({
    required this.type,
    required super.message,
    super.cause,
  });

  final LocationFailureType type;

  @override
  List<Object?> get props => [type, message, cause];
}
