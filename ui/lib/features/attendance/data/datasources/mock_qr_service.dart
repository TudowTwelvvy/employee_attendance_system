import '../models/qr_validation_result.dart';

/// MockQRService simulates QR code validation with location data.
class MockQRService {
  /// Mock database of valid QR codes with GPS coordinates
  /// 
  /// Each site now has:
  /// - siteId, siteName (from before)
  /// - latitude, longitude (center of the site)
  /// - radiusInMeters (geofence size)
  static final Map<String, Map<String, dynamic>> _validQRCodes = {
    'SITE-HQ-001': {
      'siteId': 'site_001',
      'siteName': 'Head Office',
      'latitude': -25.7479,  // Pretoria, South Africa (example)
      'longitude': 28.2293,
      'radiusInMeters': 100.0, // Must be within 100 meters
    },
    'SITE-A-002': {
      'siteId': 'site_002',
      'siteName': 'Construction Site A',
      'latitude': -25.7600,
      'longitude': 28.2400,
      'radiusInMeters': 200.0, // Larger area for construction
    },
    'SITE-B-003': {
      'siteId': 'site_003',
      'siteName': 'Warehouse B',
      'latitude': -25.7300,
      'longitude': 28.2100,
      'radiusInMeters': 150.0,
    },
    '6009710723586': {
      'siteId': 'site_004',
      'siteName': 'Warehouse Twelvvy',
      'latitude': -25.85891,  // Pretoria, South Africa (example)
      'longitude': 28.18577,
      'radiusInMeters': 30000.0,
    },
  };

  static Future<QrValidationResult> validateQrCode(String qrValue) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final siteData = _validQRCodes[qrValue];

    if (siteData != null) {
      return QrValidationResult.valid(
        siteId: siteData['siteId'] as String,
        siteName: siteData['siteName'] as String,
        //Pass location data for geofence check
        latitude: siteData['latitude'] as double,
        longitude: siteData['longitude'] as double,
        radiusInMeters: siteData['radiusInMeters'] as double,
      );
    }

    return QrValidationResult.invalid(
      'Invalid QR code: "$qrValue" is not registered to any site.',
    );
  }

  static List<String> getMockQRCodes() {
    return _validQRCodes.keys.toList();
  }
}