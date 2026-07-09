import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/attendance_report_model.dart';

class ReportExportService {
  ReportExportService._();
  static final ReportExportService _instance = ReportExportService._();
  factory ReportExportService() => _instance;

  static const List<String> _csvHeaders = [
    'Employee Name',
    'Site',
    'Date',
    'Check-In Time',
    'Status',
    'Latitude',
    'Longitude',
    'Device',
  ];

  String exportToCSV(List<AttendanceReportModel> records) {
    final buffer = StringBuffer();
    buffer.writeln(_csvHeaders.join(','));

    for (final record in records) {
      final row = record
          .toRow()
          .map((cell) {
            final text = cell.toString();
            if (text.contains(',') || text.contains('"')) {
              return '"${text.replaceAll('"', '""')}"';
            }
            return text;
          })
          .join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  Uint8List exportToExcel(List<AttendanceReportModel> records) {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance Report'];

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));

    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Attendance Report');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
    );

    for (int i = 0; i < _csvHeaders.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2),
      );

      cell.value = TextCellValue(_csvHeaders[i]);

      // FIX: use backgroundColorHex / fontColorHex with ExcelColor objects
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('6C63FF'),
        fontColorHex: ExcelColor.fromHexString('FFFFFF'),
      );
    }

    for (int rowIndex = 0; rowIndex < records.length; rowIndex++) {
      final record = records[rowIndex];
      final row = record.toRow();

      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: colIndex,
            rowIndex: rowIndex + 3,
          ),
        );

        cell.value = TextCellValue(row[colIndex].toString());
      }
    }

    for (int i = 0; i < _csvHeaders.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    return Uint8List.fromList(excel.encode()!);
  }

  Future<Uint8List> exportToPDF(
    List<AttendanceReportModel> records,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    final total = records.length;
    final onTime = records.where((r) => r.status == 'On Time').length;
    final late = records.where((r) => r.status == 'Late').length;
    final absent = records.where((r) => r.status == 'Absent').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Attendance Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#6C63FF'),
                    ),
                  ),
                  pw.Text(
                    '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return [
            pw.Text(
              'Summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                _buildSummaryBox(
                  'Total Records',
                  total.toString(),
                  PdfColors.blue,
                ),
                _buildSummaryBox('On Time', onTime.toString(), PdfColors.green),
                _buildSummaryBox('Late', late.toString(), PdfColors.orange),
                _buildSummaryBox('Absent', absent.toString(), PdfColors.red),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Detailed Records',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: _csvHeaders,
              data: records
                  .map((r) => r.toRow().map((c) => c.toString()).toList())
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              // FIX: removed const — PdfColor.fromHex is not a const constructor
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#6C63FF'),
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildSummaryBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.all(4),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color),
          // FIX: removed const — pw.Radius.circular is not a const constructor
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
