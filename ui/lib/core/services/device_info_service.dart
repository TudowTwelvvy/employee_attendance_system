import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService _instance = DeviceInfoService._();
  factory DeviceInfoService() => _instance;

  /// Cached device info (so we don't read it multiple times)
  DeviceInfo? _cachedInfo;

  /// Get all device and app information
  /// Returns a DeviceInfo object with everything we need.
  Future<DeviceInfo> getDeviceInfo() async {
    // If we already read the info, return cached version
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    // Create the plugin instances
    final deviceInfoPlugin = DeviceInfoPlugin();

    // Read app information (version, build number)
    final packageInfo = await PackageInfo.fromPlatform();
    
    // Read device information (different for Android vs iOS)
    String brand = 'Unknown';
    String model = 'Unknown';
    String os = 'Unknown';
    String osVersion = 'Unknown';

    // Platform.isAndroid and Platform.isIOS tell us which OS we're on
    if (Platform.isAndroid) {
      // Android-specific info
      final androidInfo = await deviceInfoPlugin.androidInfo;
      brand = androidInfo.brand;      // e.g., "samsung"
      model = androidInfo.model;      // e.g., "SM-G991B"
      os = 'Android';
      osVersion = androidInfo.version.release; // e.g., "14"
    } else if (Platform.isIOS) {
      // iOS-specific info
      final iosInfo = await deviceInfoPlugin.iosInfo;
      brand = 'Apple';
      model = iosInfo.utsname.machine;// e.g., "iPhone14,2"
      os = 'iOS';
      osVersion = iosInfo.systemVersion; // e.g., "17.1"
    }

    // Create and cache the result
    _cachedInfo = DeviceInfo(
      deviceName: '$brand $model',
      deviceModel: model,
      operatingSystem: os,
      osVersion: osVersion,
      appVersion: packageInfo.version,      // e.g., "1.0.0"
      appBuildNumber: packageInfo.buildNumber, // e.g., "1"
    );

    return _cachedInfo!;
  }
}

/// Data class that holds all device information
/// 
/// This is a simple "container" with no logic — just data.
class DeviceInfo {
  final String deviceName;        // "Samsung Galaxy S21"
  final String deviceModel;       // "SM-G991B"
  final String operatingSystem;   // "Android"
  final String osVersion;         // "14"
  final String appVersion;        // "1.0.0"
  final String appBuildNumber;    // "1"

  const DeviceInfo({
    required this.deviceName,
    required this.deviceModel,
    required this.operatingSystem,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
  });

  /// Convert to a Map for sending to API
  /// 
  /// When we submit attendance, we send this data as JSON.
  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'operatingSystem': operatingSystem,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
    };
  }

  @override
  String toString() {
    return 'DeviceInfo($deviceName, $osVersion, App $appVersion)';
  }
}