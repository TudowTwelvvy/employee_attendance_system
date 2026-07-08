import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../data/datasources/mock_site_service.dart';
import '../../data/models/site_model.dart';

class QRGenerationScreen extends ConsumerStatefulWidget {
  const QRGenerationScreen({super.key});

  @override
  ConsumerState<QRGenerationScreen> createState() => _QRGenerationScreenState();
}

class _QRGenerationScreenState extends ConsumerState<QRGenerationScreen> {
  String? _selectedSiteId;
  String? _qrData;
  final TextEditingController _customTextController = TextEditingController();

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSizes(context);
    final sites = MockSiteService.getAllSites();

    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Codes')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900 && sizes.isDesktop) {
              return _buildDesktopLayout(sites, sizes, constraints);
            }
            return _buildMobileLayout(sites, sizes);
          },
        ),
      ),
    );
  }

  // DESKTOP LAYOUT
  Widget _buildDesktopLayout(
    List<SiteModel> sites,
    ResponsiveSizes sizes,
    BoxConstraints constraints,
  ) {
    final contentWidth = constraints.maxWidth > 1200
        ? 1200.0
        : constraints.maxWidth;

    return Padding(
      padding: EdgeInsets.all(sizes.paddingHorizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Controls — scrollable so buttons never overflow
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: SingleChildScrollView(
                  child: _buildControlsPanel(sites, sizes, true),
                ),
              ),
              SizedBox(width: 32.w),

              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: SingleChildScrollView(child: _buildQRPreview(true)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout(List<SiteModel> sites, ResponsiveSizes sizes) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(sizes.paddingHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildControlsPanel(sites, sizes, false),
            SizedBox(height: 24.h),
            _buildQRPreview(false),
          ],
        ),
      ),
    );
  }

  // ─── CONTROLS PANEL ───
  Widget _buildControlsPanel(
    List<SiteModel> sites,
    ResponsiveSizes sizes,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Select a Site', style: AppTheme.headingMedium(context)),
        SizedBox(height: sizes.spaceSmall),
        Text(
          'Choose a work site to generate its QR code',
          style: AppTheme.bodyLarge(context),
        ),
        SizedBox(height: sizes.spaceLarge),

        // Site dropdown
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Work Site',
            hintText: 'Select a site...',
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 12.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
          value: _selectedSiteId,

          selectedItemBuilder: (context) {
            return sites.map((site) {
              return Row(
                children: [
                  Icon(
                    site.isActive ? Icons.check_circle : Icons.cancel,
                    color: site.isActive ? Colors.green : Colors.grey,
                    size: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      site.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          // This controls how items look in the OPENED dropdown menu
          items: sites.map((site) {
            return DropdownMenuItem<String>(
              value: site.id,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 56.h),
                child: Row(
                  children: [
                    Icon(
                      site.isActive ? Icons.check_circle : Icons.cancel,
                      color: site.isActive ? Colors.green : Colors.grey,
                      size: 18.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            site.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            site.qrCodeValue,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSiteId = newValue;
              _qrData = null;
            });
          },
        ),
        SizedBox(height: sizes.spaceLarge),

        // OR divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: sizes.spaceLarge),

        // Custom text input
        TextField(
          controller: _customTextController,
          decoration: InputDecoration(
            labelText: 'Custom QR Text',
            hintText: 'Enter any text to encode...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            prefixIcon: const Icon(Icons.edit),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _customTextController.clear();
                setState(() => _qrData = null);
              },
            ),
          ),
          onChanged: (_) => setState(() => _qrData = null),
        ),

        SizedBox(height: sizes.spaceLarge),

        // Generate button
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 48.h : 50.h,
          child: ElevatedButton.icon(
            onPressed: _generateQR,
            icon: const Icon(Icons.qr_code),
            label: const Text('GENERATE QR CODE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Print button
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 48.h : 50.h,
          child: ElevatedButton.icon(
            onPressed: _qrData != null ? _printQR : null,
            icon: const Icon(Icons.print),
            label: const Text('PRINT QR CODE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Download button
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 48.h : 50.h,
          child: OutlinedButton.icon(
            onPressed: _qrData != null ? _downloadQR : null,
            icon: const Icon(Icons.download),
            label: const Text('DOWNLOAD AS PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // QR PREVIEW PANEL
  Widget _buildQRPreview(bool isDesktop) {
    if (_qrData == null || _qrData!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: EdgeInsets.all(24.r),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code,
                size: isDesktop ? 120.r : 80.r,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'QR code will appear here',
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select a site or enter text, then tap Generate',
                style: TextStyle(
                  fontSize: isDesktop ? 14.sp : 12.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      padding: EdgeInsets.all((isDesktop ? 48 : 24).r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedSiteId != null) ...[
            Text(
              _getSiteName(_selectedSiteId!),
              style: TextStyle(
                fontSize: isDesktop ? 24.sp : 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _qrData!,
              style: TextStyle(
                fontSize: isDesktop ? 16.sp : 14.sp,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 24.h),
          ],

          QrImageView(
            data: _qrData!,
            version: QrVersions.auto,
            size: isDesktop ? 300.r : 200.r,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            errorStateBuilder: (context, error) {
              return Center(
                child: Text(
                  'Error generating QR',
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          Text(
            'Scan this QR code to check in',
            style: TextStyle(
              fontSize: isDesktop ? 16.sp : 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // HELPERS
  String _getSiteName(String siteId) {
    final sites = MockSiteService.getAllSites();
    final site = sites.firstWhere(
      (s) => s.id == siteId,
      orElse: () => SiteModel(
        id: '',
        name: 'Unknown Site',
        address: '',
        latitude: 0,
        longitude: 0,
        radiusInMeters: 0,
        qrCodeValue: '',
      ),
    );
    return site.name;
  }

  void _generateQR() {
    if (_selectedSiteId != null) {
      final sites = MockSiteService.getAllSites();
      final site = sites.firstWhere(
        (s) => s.id == _selectedSiteId,
        orElse: () => SiteModel(
          id: '',
          name: '',
          address: '',
          latitude: 0,
          longitude: 0,
          radiusInMeters: 0,
          qrCodeValue: '',
        ),
      );
      setState(() => _qrData = site.qrCodeValue);
      return;
    }

    final customText = _customTextController.text.trim();
    if (customText.isNotEmpty) {
      setState(() => _qrData = customText);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a site or enter custom text'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _printQR() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: _qrData!,
                  width: 250,
                  height: 250,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _qrData!,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Scan to check in',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _downloadQR() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: _qrData!,
                  width: 250,
                  height: 250,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _qrData!,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Scan to check in',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'qr_code_${_qrData!.replaceAll(' ', '_')}.pdf',
    );
  }
}
