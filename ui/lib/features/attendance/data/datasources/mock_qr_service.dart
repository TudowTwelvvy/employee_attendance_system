import '../models/qr_validation_result.dart';

/// MockQRService simulates QR code validation without a real API.
/// 
/// Think of this as a "fake security guard" it checks name tags
/// against a list it memorized, instead of calling the real office.
/// 
/// In production, this would call the ASP.NET API to check if the
/// QR code belongs to a valid work site.
class MockQRService {
  
  static final Map<String, Map<String, String>> _validQRCodes = {
    'SITE-HQ-001': {
      'siteId': 'site_001',
      'siteName': 'Head Office',
    },
    'SITE-A-002': {
      'siteId': 'site_002',
      'siteName': 'Construction Site A',
    },
    'SITE-B-003': {
      'siteId': 'site_003',
      'siteName': 'Warehouse B',
    },
    '6009710723586': {
      'siteId': 'site_004',
      'siteName': 'Warehouse ysg',
    },
  };


  static Future<QrValidationResult> validateQrCode(String qrValue) async {
    // Simulate API call delay — makes it feel real
    await Future.delayed(const Duration(milliseconds: 500));

    // Look up the QR code in our mock database
    final siteData = _validQRCodes[qrValue];

    if (siteData != null) {
      // Found! Return success
      return QrValidationResult.valid(
        siteId: siteData['siteId']!,
        siteName: siteData['siteName']!,
      );
    }

    // Not found! Return failure
    return QrValidationResult.invalid(
      'Invalid QR code: "$qrValue" is not registered to any site.',
    );
  }

  /// Get list of mock QR codes for testing
  static List<String> getMockQRCodes() {
    return _validQRCodes.keys.toList();
  }
}