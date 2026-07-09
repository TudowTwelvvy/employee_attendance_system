import '../models/employee_location_model.dart';
import '../models/site_model.dart';
import 'mock_site_service.dart';

class MockLocationTrackingService {
  MockLocationTrackingService._();
  static final MockLocationTrackingService _instance =
      MockLocationTrackingService._();
  factory MockLocationTrackingService() => _instance;

  List<EmployeeLocationModel> getLiveLocations() {
    final sites = MockSiteService.getAllSites();
    final now = DateTime.now();

    return [
      _createEmployee(
        'emp_001',
        'John Smith',
        sites[0],
        now.subtract(const Duration(minutes: 2)),
        'checked_in',
      ),
      _createEmployee(
        'emp_002',
        'Sarah Johnson',
        sites[1],
        now.subtract(const Duration(minutes: 5)),
        'checked_in',
      ),
      _createEmployee(
        'emp_003',
        'Michael Brown',
        sites[2],
        now.subtract(const Duration(minutes: 1)),
        'checked_in',
      ),
      _createEmployee(
        'emp_004',
        'Emily Davis',
        sites[0],
        now.subtract(const Duration(hours: 2)),
        'checked_out',
      ),
      _createEmployee(
        'emp_005',
        'David Wilson',
        sites[1],
        now.subtract(const Duration(minutes: 30)),
        'offline',
      ),
    ];
  }

  /// Create an employee location with slight GPS offset from site center.
  EmployeeLocationModel _createEmployee(
    String id,
    String name,
    SiteModel site,
    DateTime lastUpdated,
    String status,
  ) {
    // Add small random offset so pins don't stack perfectly on top of each other
    // Like spreading out name tags at a conference table
    final latOffset =
        (id.hashCode % 100) / 10000; // ~0.001 degrees = ~100 meters
    final lngOffset = ((id.hashCode + 50) % 100) / 10000;

    return EmployeeLocationModel(
      employeeId: id,
      employeeName: name,
      siteId: site.id,
      siteName: site.name,
      latitude: site.latitude + latOffset,
      longitude: site.longitude + lngOffset,
      lastUpdated: lastUpdated,
      status: status,
      deviceName: 'Samsung Galaxy S21',
    );
  }
}
