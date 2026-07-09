import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_sizes.dart';
import '../../data/datasources/mock_report_service.dart';
import '../../data/models/attendance_report_model.dart';
import '../../data/services/report_export_service.dart';

class AttendanceReportsScreen extends ConsumerStatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  ConsumerState<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState
    extends ConsumerState<AttendanceReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<AttendanceReportModel> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _records = MockReportService.generateReport(_startDate, _endDate);
        _isLoading = false;
      });
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;
                  return isDesktop
                      ? _buildDesktopLayout(constraints)
                      : _buildMobileLayout();
                },
              ),
      ),
    );
  }

  // DESKTOP
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    final total = _records.length;
    final onTime = _records.where((r) => r.status == 'On Time').length;
    final late = _records.where((r) => r.status == 'Late').length;
    final absent = _records.where((r) => r.status == 'Absent').length;

    final contentWidth = constraints.maxWidth > 1400 ? 1400.0 : constraints.maxWidth;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildDateRangePicker(true),
                SizedBox(height: 24.h),
                _buildSummaryCards(total, onTime, late, absent, true),
                SizedBox(height: 24.h),

                // Charts row
                SizedBox(
                  height: 350.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildBarChart(true)),
                      SizedBox(width: 24.w),
                      Expanded(flex: 2, child: _buildPieChart(total, onTime, late, absent, true)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                _buildDownloadButtons(true),
                SizedBox(height: 24.h),

               
                SizedBox(
                  height: 400.h,
                  child: _buildDataTable(true),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MOBILE: Vertical scroll, NO Expanded anywhere ───
  Widget _buildMobileLayout() {
    final total = _records.length;
    final onTime = _records.where((r) => r.status == 'On Time').length;
    final late = _records.where((r) => r.status == 'Late').length;
    final absent = _records.where((r) => r.status == 'Absent').length;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildDateRangePicker(false),
            SizedBox(height: 16.h),
            _buildSummaryCards(total, onTime, late, absent, false),
            SizedBox(height: 16.h),
            SizedBox(height: 220.h, child: _buildBarChart(false)),
            SizedBox(height: 16.h),
            SizedBox(height: 280.h, child: _buildPieChart(total, onTime, late, absent, false)),
            SizedBox(height: 16.h),
            _buildDownloadButtons(false),
            SizedBox(height: 16.h),
            _buildMobileDataTable(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Attendance Reports',
          style: AppTheme.headingMedium(context),
        ),
        SizedBox(height: 4.h),
        Text(
          'Analyze attendance patterns and export data',
          style: AppTheme.bodyLarge(context),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16.w : 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isDesktop
          ? Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20.r),
                SizedBox(width: 12.w),
                Text(
                  'Date Range:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(child: _buildDateChip(true)),
                SizedBox(width: 12.w),
                Text('to', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                SizedBox(width: 12.w),
                Expanded(child: _buildDateChip(false)),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Date Range:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildDateChip(true)),
                    SizedBox(width: 8.w),
                    Text('to', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildDateChip(false)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDateChip(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    return InkWell(
      onTap: () => _pickDate(isStart),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, size: 16.r, color: Colors.grey),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(fontSize: 13.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    int total,
    int onTime,
    int late,
    int absent,
    bool isDesktop,
  ) {
    final cards = [
      _SummaryCard(label: 'Total', value: total.toString(), color: Colors.blue, icon: Icons.people),
      _SummaryCard(label: 'On Time', value: onTime.toString(), color: Colors.green, icon: Icons.check_circle),
      _SummaryCard(label: 'Late', value: late.toString(), color: Colors.orange, icon: Icons.access_time),
      _SummaryCard(label: 'Absent', value: absent.toString(), color: Colors.red, icon: Icons.cancel),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((card) => Expanded(child: card)).toList(),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.5,
      children: cards,
    );
  }

  Widget _buildBarChart(bool isDesktop) {
    final dailyData = <DateTime, Map<String, int>>{};
    for (final record in _records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      dailyData.putIfAbsent(date, () => {'On Time': 0, 'Late': 0, 'Absent': 0});
      dailyData[date]![record.status] = (dailyData[date]![record.status] ?? 0) + 1;
    }

    final sortedDates = dailyData.keys.toList()..sort();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.w : 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Daily Attendance',
            style: TextStyle(fontSize: isDesktop ? 16.sp : 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: sortedDates.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: Colors.grey, fontSize: 12.sp)))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(dailyData),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= sortedDates.length) return const SizedBox.shrink();
                              final date = sortedDates[idx];
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                                ),
                              );
                            },
                            reservedSize: 28.h,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28.w,
                            interval: 1,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(sortedDates.length, (index) {
                        final date = sortedDates[index];
                        final data = dailyData[date]!;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            _buildBarRod(data['On Time'] ?? 0, Colors.green, isDesktop),
                            _buildBarRod(data['Late'] ?? 0, Colors.orange, isDesktop),
                            _buildBarRod(data['Absent'] ?? 0, Colors.red, isDesktop),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BarChartRodData _buildBarRod(int value, Color color, bool isDesktop) {
    return BarChartRodData(
      toY: value.toDouble(),
      color: color,
      width: isDesktop ? 10.w : 6.w,
      borderRadius: BorderRadius.circular(2.r),
    );
  }

  double _calculateMaxY(Map<DateTime, Map<String, int>> dailyData) {
    int max = 0;
    for (final data in dailyData.values) {
      final total = (data['On Time'] ?? 0) + (data['Late'] ?? 0) + (data['Absent'] ?? 0);
      if (total > max) max = total;
    }
    return max == 0 ? 5 : (max + 1).toDouble();
  }

  Widget _buildPieChart(int total, int onTime, int late, int absent, bool isDesktop) {
    if (total == 0) return _buildEmptyChart('No data', isDesktop);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20.w : 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Status Breakdown',
            style: TextStyle(fontSize: isDesktop ? 16.sp : 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: isDesktop ? 40.r : 30.r,
                sections: [
                  _buildPieSection(onTime, total, Colors.green, 'On Time'),
                  _buildPieSection(late, total, Colors.orange, 'Late'),
                  _buildPieSection(absent, total, Colors.red, 'Absent'),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _buildLegend('On Time', onTime, Colors.green),
          _buildLegend('Late', late, Colors.orange),
          _buildLegend('Absent', absent, Colors.red),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(int value, int total, Color color, String label) {
    final percentage = total > 0 ? (value / total * 100) : 0;
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: percentage > 0 ? '${percentage.toStringAsFixed(0)}%' : '',
      radius: 50.r,
      titleStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegend(String label, int value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Container(width: 10.w, height: 10.w, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r))),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message, bool isDesktop) {
    return Container(
      height: isDesktop ? 250.h : 200.h,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
      child: Center(child: Text(message, style: TextStyle(color: Colors.grey, fontSize: 14.sp))),
    );
  }

  Widget _buildDownloadButtons(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16.w : 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Export Report', style: TextStyle(fontSize: isDesktop ? 16.sp : 14.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          isDesktop
              ? Row(
                  children: [
                    Expanded(child: _buildDownloadBtn('Excel (.xlsx)', Icons.table_chart, Colors.green, _downloadExcel)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildDownloadBtn('CSV', Icons.description, Colors.blue, _downloadCSV)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildDownloadBtn('PDF', Icons.picture_as_pdf, Colors.red, _downloadPDF)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDownloadBtn('Excel (.xlsx)', Icons.table_chart, Colors.green, _downloadExcel),
                    SizedBox(height: 8.h),
                    _buildDownloadBtn('CSV', Icons.description, Colors.blue, _downloadCSV),
                    SizedBox(height: 8.h),
                    _buildDownloadBtn('PDF', Icons.picture_as_pdf, Colors.red, _downloadPDF),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDownloadBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18.r),
        label: Text(label, style: TextStyle(fontSize: 13.sp)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      ),
    );
  }

  // DESKTOP DATA TABLE 
  Widget _buildDataTable(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 16.w : 12.w),
            child: Text('Detailed Records', style: TextStyle(fontSize: isDesktop ? 16.sp : 14.sp, fontWeight: FontWeight.bold)),
          ),
          Divider(height: 1.h),
          _buildTableHeader(isDesktop),
          Divider(height: 1.h),
          Expanded(
            child: _records.isEmpty
                ? Center(child: Text('No records found', style: TextStyle(color: Colors.grey, fontSize: 12.sp)))
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) => _buildTableRow(_records[index], index, isDesktop),
                  ),
          ),
        ],
      ),
    );
  }

  //MOBILE DATA TABLE 
  Widget _buildMobileDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text('Detailed Records', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ),
          Divider(height: 1.h),
          _buildTableHeader(false),
          Divider(height: 1.h),
          _records.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(24.h),
                  child: Center(child: Text('No records found', style: TextStyle(color: Colors.grey, fontSize: 12.sp))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _records.length,
                  itemBuilder: (context, index) => _buildTableRow(_records[index], index, false),
                ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isDesktop) {
    final headers = ['Employee', 'Site', 'Date', 'Time', 'Status'];
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isDesktop ? 12.h : 10.h),
      child: Row(
        children: headers.map((h) {
          return Expanded(
            flex: h == 'Employee' ? 2 : 1,
            child: Text(
              h,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 12.sp : 10.sp,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow(AttendanceReportModel record, int index, bool isDesktop) {
    return Container(
      color: index % 2 == 0 ? Colors.white : Colors.grey[50],
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isDesktop ? 10.h : 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(record.employeeName, style: TextStyle(fontSize: isDesktop ? 12.sp : 10.sp), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(record.siteName, style: TextStyle(fontSize: isDesktop ? 12.sp : 10.sp, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(record.formattedDate, style: TextStyle(fontSize: isDesktop ? 12.sp : 10.sp)),
          ),
          Expanded(
            child: Text(record.formattedTime, style: TextStyle(fontSize: isDesktop ? 12.sp : 10.sp)),
          ),
          Expanded(child: _buildStatusBadge(record.status)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'On Time': color = Colors.green; break;
      case 'Late': color = Colors.orange; break;
      case 'Absent': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _downloadExcel() async {
    final exportService = ReportExportService();
    final bytes = exportService.exportToExcel(_records);
    await Printing.sharePdf(bytes: bytes, filename: 'attendance_report_${_formatFileDate()}.xlsx');
  }

  Future<void> _downloadCSV() async {
    final exportService = ReportExportService();
    final csvString = exportService.exportToCSV(_records);
    final bytes = Uint8List.fromList(utf8.encode(csvString));
    await Printing.sharePdf(bytes: bytes, filename: 'attendance_report_${_formatFileDate()}.csv');
  }

  Future<void> _downloadPDF() async {
    final exportService = ReportExportService();
    final bytes = await exportService.exportToPDF(_records, _startDate, _endDate);
    await Printing.sharePdf(bytes: bytes, filename: 'attendance_report_${_formatFileDate()}.pdf');
  }

  String _formatFileDate() => '${_startDate.day}_${_startDate.month}_${_startDate.year}';
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(height: 6.h),
            Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}