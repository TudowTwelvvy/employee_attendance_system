import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';

/// LocationState represents the GPS state
class LocationState {
  final bool isLoading;
  final Position? position;
  final String? errorMessage;
  final bool isWithinGeofence;
  final double? distanceFromSite;

  const LocationState({
    this.isLoading = false,
    this.position,
    this.errorMessage,
    this.isWithinGeofence = false,
    this.distanceFromSite,
  });

  /// Create a copy with some fields changed
  LocationState copyWith({
    bool? isLoading,
    Position? position,
    String? errorMessage,
    bool? isWithinGeofence,
    double? distanceFromSite,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
      isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
      distanceFromSite: distanceFromSite ?? this.distanceFromSite,
    );
  }
}

/// LocationNotifier manages GPS operations
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// Get current location and check geofence
  Future<void> getLocationAndValidate({
    required double siteLatitude,
    required double siteLongitude,
    required double radiusInMeters,
  }) async {
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get GPS position
      final position = await LocationService.getCurrentPosition();

      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not get location. Please enable GPS and grant permission.',
        );
        return;
      }

      // Calculate distance from site
      final distance = LocationService.calculateDistance(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: siteLatitude,
        endLongitude: siteLongitude,
      );

      //Check if within geofence
      final withinGeofence = LocationService.isWithinGeofence(
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
        centerLatitude: siteLatitude,
        centerLongitude: siteLongitude,
        radiusInMeters: radiusInMeters,
      );

      // Update state with results
      state = state.copyWith(
        isLoading: false,
        position: position,
        distanceFromSite: distance,
        isWithinGeofence: withinGeofence,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Location error: ${e.toString()}',
      );
    }
  }

  /// Clear location data
  void clear() {
    state = const LocationState();
  }
}

/// Provider that widgets use to access location state
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});