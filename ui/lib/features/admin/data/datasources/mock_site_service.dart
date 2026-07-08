import '../models/site_model.dart';

/// MockSiteService provides fake work site data.
class MockSiteService {
  static final List<SiteModel> _sites = [
    SiteModel(
      id: 'site_001',
      name: 'Head Office',
      address: '123 Main Street, Pretoria CBD',
      latitude: -25.7479,
      longitude: 28.2293,
      radiusInMeters: 100,
      qrCodeValue: 'SITE-HQ-001',
      description: 'Main corporate headquarters',
      isActive: true,
    ),
    SiteModel(
      id: 'site_002',
      name: 'Construction Site A',
      address: '45 Builder Road, Centurion',
      latitude: -25.8600,
      longitude: 28.1900,
      radiusInMeters: 200,
      qrCodeValue: 'SITE-A-002',
      description: 'New shopping mall construction',
      isActive: true,
    ),
    SiteModel(
      id: 'site_003',
      name: 'Warehouse B',
      address: '78 Industrial Ave, Midrand',
      latitude: -25.9900,
      longitude: 28.1300,
      radiusInMeters: 150,
      qrCodeValue: 'SITE-B-003',
      description: 'Storage and distribution center',
      isActive: true,
    ),
    SiteModel(
      id: 'site_004',
      name: 'Remote Office',
      address: '12 Suburban Lane, Sandton',
      latitude: -26.1100,
      longitude: 28.0500,
      radiusInMeters: 75,
      qrCodeValue: 'SITE-REM-004',
      description: 'Satellite office for sales team',
      isActive: false,
    ),
  ];

  static List<SiteModel> getAllSites() {
    return List<SiteModel>.from(_sites);
  }

  static SiteModel? getSiteById(String id) {
    return _sites.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Site not found'),
    );
  }
}
