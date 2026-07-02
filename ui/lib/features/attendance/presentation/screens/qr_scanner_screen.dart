import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/mock_qr_service.dart';
import '../../data/models/qr_validation_result.dart';


class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  /// Tracks if we're currently handling a scan
  /// 
  ///The camera detects QR codes continuously. Without this flag,
  /// one QR code would trigger the handler 10+ times per second!
  bool _isProcessing = false;

  /// Controls the camera: start, stop, toggle flash, switch camera
  MobileScannerController? _controller;

  /// Dispose is called when this screen is destroyed (user navigates away).
  /// 
  /// We MUST dispose the controller to release the camera.
  /// If we don't, the camera stays on and drains battery!
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Called automatically when the camera detects a QR code
  /// 
  /// 'BarcodeCapture' contains all detected barcodes in the current frame.
  Future<void> _onDetect(BarcodeCapture capture) async {
    //If already processing, ignore this detection
    if (_isProcessing) return;

    // Get the list of detected barcodes
    final List<Barcode> barcodes = capture.barcodes;
    
    // No barcodes detected (shouldn't happen, but safety first)
    if (barcodes.isEmpty) return;

    // Get the raw text value from the first barcode
    final String? qrValue = barcodes.first.rawValue;
    
    // Empty QR code
    if (qrValue == null || qrValue.isEmpty) return;

    // Mark as processing to prevent duplicate scans
    setState(() => _isProcessing = true);

    // Stop camera to save resources while we validate
    _controller?.stop();

    // Validate the QR code with our mock service
    final result = await MockQRService.validateQrCode(qrValue);

    //User navigated away while we were validating
    if (!mounted) return;

    if (result.isValid) {
      // SUCCESS: Show confirmation dialog
      _showSuccessDialog(result);
    } else {
      // FAILURE: Show error and resume scanning
      _showErrorDialog(result.message ?? 'Unknown error');
    }
  }

  /// Shows a success dialog with site information
  void _showSuccessDialog(QrValidationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false, // User MUST tap a button, can't tap outside
      builder: (context) => AlertDialog(
        // Rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            // Green checkmark icon
            Icon(Icons.check_circle, color: Colors.green, size: 32.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Valid QR Code!',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          // Make column as small as possible (wrap content)
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Site: ${result.siteName}', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 8.h),
            Text(
              'Site ID: ${result.siteId}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            Text(
              'Proceed to mark attendance?',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          // Cancel button.. go back to scanning
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resumeScanning(); // Start camera again
            },
            child: const Text('Cancel'),
          ),
          // Proceed button — go to confirmation screen
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to attendance confirmation WITH data
              context.push(
                '/attendance/confirm',
                extra: {
                  'siteId': result.siteId,
                  'siteName': result.siteName,
                },
              );
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  /// Shows an error dialog when QR is invalid
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Invalid QR Code',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Resumes scanning after a dialog is closed
  void _resumeScanning() {
    setState(() => _isProcessing = false);
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          // Flashlight toggle button
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller?.toggleTorch(),
          ),
          // Switch camera (front/back) button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        // Stack layers widgets on top of each other
        children: [
          // LAYER 1: Camera preview (fills entire screen)
MobileScanner(
  controller: _controller ??= MobileScannerController(),
  onDetect: _onDetect,
),

// LAYER 2: Scanning frame overlay (center of screen)
Center(
  child: Container(
    width: 250.w,
    height: 250.w,
    decoration: BoxDecoration(
      border: Border.all(
        color: _isProcessing ? Colors.orange : AppTheme.primaryColor,
        width: 4,
      ),
      borderRadius: BorderRadius.circular(16.r),
    ),
  ),
),

          // LAYER 2: Scanning frame (center of screen)
          Center(
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.orange : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),

          // LAYER 3: Instructions at bottom
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  _isProcessing ? 'Processing...' : 'Align QR code within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),

          // LAYER 4: Mock QR codes for testing (top of screen)
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Test QR Codes:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Map each mock code to a Text widget
                    ...MockQRService.getMockQRCodes().map(
                      (code) => Text(
                        code,
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 11.sp,
                          fontFamily: 'monospace', // Fixed-width font
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}