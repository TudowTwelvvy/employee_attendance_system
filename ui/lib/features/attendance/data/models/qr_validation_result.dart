
class QrValidationResult {
  final bool isValid;
  final String? siteId;
  final String? siteName;
  final String? message;

  QrValidationResult({
    required this.isValid,
    this.siteId,
    this.siteName,
    this.message,
  });

  /// Factory constructor for a VALID QR code result
  /// 
  /// 'factory' means this is a special constructor that can decide
  /// how to create the object. It's like a custom recipe.
  factory QrValidationResult.valid({
    required String siteId,
    required String siteName,
  }) {
    return QrValidationResult(
      isValid: true,
      siteId: siteId,
      siteName: siteName,
      message: 'Valid QR code for $siteName',
    );
  }

  /// Factory constructor for an INVALID QR code result
  factory QrValidationResult.invalid(String reason) {
    return QrValidationResult(
      isValid: false,
      message: reason,
    );
  }
}