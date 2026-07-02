class QrValidationResult {
  final bool isValid;
  final String? siteId;
  final String? siteName;
  final double? latitude;      // Site center latitude
  final double? longitude;     // Site center longitude
  final double? radiusInMeters; //Allowed distance from center
  final String? message;

  QrValidationResult({
    required this.isValid,
    this.siteId,
    this.siteName,
    this.latitude,
    this.longitude,
    this.radiusInMeters,
    this.message,
  });

  factory QrValidationResult.valid({
    required String siteId,
    required String siteName,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
  }) {
    return QrValidationResult(
      isValid: true,
      siteId: siteId,
      siteName: siteName,
      latitude: latitude,
      longitude: longitude,
      radiusInMeters: radiusInMeters,
      message: 'Valid QR code for $siteName',
    );
  }

  factory QrValidationResult.invalid(String reason) {
    return QrValidationResult(
      isValid: false,
      message: reason,
    );
  }
}