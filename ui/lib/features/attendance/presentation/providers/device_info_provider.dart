import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/device_info_service.dart';

/// DeviceInfoState holds the device information
class DeviceInfoState {
  final bool isLoading;
  final DeviceInfo? deviceInfo;
  final String? errorMessage;

  const DeviceInfoState({
    this.isLoading = false,
    this.deviceInfo,
    this.errorMessage,
  });

  DeviceInfoState copyWith({
    bool? isLoading,
    DeviceInfo? deviceInfo,
    String? errorMessage,
  }) {
    return DeviceInfoState(
      isLoading: isLoading ?? this.isLoading,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// DeviceInfoNotifier manages reading device info
class DeviceInfoNotifier extends StateNotifier<DeviceInfoState> {
  DeviceInfoNotifier() : super(const DeviceInfoState());

  /// Read device information
  Future<void> loadDeviceInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final deviceInfo = await DeviceInfoService().getDeviceInfo();
      state = state.copyWith(isLoading: false, deviceInfo: deviceInfo);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to read device info: ${e.toString()}',
      );
    }
  }
}

/// Provider that widgets use to access device info
final deviceInfoProvider = StateNotifierProvider<DeviceInfoNotifier, DeviceInfoState>((ref) {
  return DeviceInfoNotifier();
});