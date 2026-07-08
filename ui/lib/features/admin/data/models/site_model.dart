class SiteModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final String qrCodeValue;
  final String? description;
  final bool isActive;

  SiteModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.qrCodeValue,
    this.description,
    this.isActive = true,
  });

  /// Create from JSON (for future API)
  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusInMeters: (json['radiusInMeters'] as num?)?.toDouble() ?? 100.0,
      qrCodeValue: json['qrCodeValue'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
      'qrCodeValue': qrCodeValue,
      'description': description,
      'isActive': isActive,
    };
  }

  /// Format coordinates for display
  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
  }

  //Get static map image URL.. using OpenStreetMap static tiles)
  //This is a FREE way to show a map without an API key.
  //but i will use Google Maps Static API later which is paid
  String get staticMapUrl {
    // OpenStreetMap static image (free, no API key needed)
    // zoom=15, marker at site location
    return 'https://static-maps.openstreetmap.de/staticmap.php?'
        'center=$latitude,$longitude'
        '&zoom=15'
        '&size=600x400'
        '&markers=$latitude,$longitude,ol-marker'
        '&maptype=mapnik';
  }
}
