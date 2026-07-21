import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/geolocator_location_tracking_repository.dart';
import '../domain/repositories/location_tracking_repository.dart';

final locationTrackingRepositoryProvider = Provider<LocationTrackingRepository>(
  (ref) {
    return GeolocatorLocationTrackingRepository();
  },
);
