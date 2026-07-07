import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  LocationService._();
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  /// Check if location permission is granted
  ///
  /// Returns true if we can use GPS, false if not.
  static Future<bool> isPermissionGranted() async {
    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // If denied, request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Return true only if allowed (while using app or always)
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get current GPS position
  ///
  /// This is an async operation because:
  /// - GPS takes time to "warm up" (find satellites)
  /// - The OS might show a permission dialog
  /// - The user might deny permission
  ///
  /// Returns a Position object with latitude, longitude, accuracy, etc.
  static Future<Position?> getCurrentPosition() async {
    if (kIsWeb) {
      return Position(
        longitude: 28.2293,
        latitude: -25.7479,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    // First, check permission
    final hasPermission = await isPermissionGranted();

    if (!hasPermission) {
      return null; // Can't get location without permission
    }

    // Check if GPS is enabled on the device
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return null; // GPS is turned off in phone settings
    }

    // Get current position with high accuracy
    // desiredAccuracy: best = use GPS satellites (most accurate)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// Calculate distance between two points on Earth
  ///
  /// Uses the Haversine formula (spherical geometry).
  /// Returns distance in METERS.
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if a position is within a geofence.
  static bool isWithinGeofence({
    required double currentLatitude,
    required double currentLongitude,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusInMeters,
  }) {
    final distance = calculateDistance(
      startLatitude: currentLatitude,
      startLongitude: currentLongitude,
      endLatitude: centerLatitude,
      endLongitude: centerLongitude,
    );

    // If distance is less than radius, we're inside
    return distance <= radiusInMeters;
  }
}
