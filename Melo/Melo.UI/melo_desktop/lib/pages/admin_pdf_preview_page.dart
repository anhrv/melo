import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/datetime_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class AdminPdfPreviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String entity;
  final String sortBy;
  final bool ascending;

  const AdminPdfPreviewPage({
    super.key,
    required this.data,
    required this.entity,
    required this.sortBy,
    required this.ascending,
  });

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final hasLikes = data.any((item) => item.containsKey('likeCount'));

    final headers = ['Name', 'Views', if (hasLikes) 'Likes'];

    final rows = data.map((item) {
      return [
        item['name']?.toString() ?? '',
        item['viewCount']?.toString() ?? '0',
        if (hasLikes) item['likeCount']?.toString() ?? '0',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Melo',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Top ${data.length} ${ascending ? 'Least' : 'Most'} ${sortBy == 'likeCount' ? 'Liked' : 'Viewed'} ${entity[0].toUpperCase()}${entity.substring(1)}s Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              DateTimeUtil.formatUtcToLocal(DateTime.now().toUtc().toString()),
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            cellStyle: const pw.TextStyle(fontSize: 12),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignments: {
              1: pw.Alignment.center,
              if (hasLikes) 2: pw.Alignment.center,
            },
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              if (hasLikes) 2: const pw.FlexColumnWidth(1),
            },
          )
        ],
      ),
    );

    return pdf.save();
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else {
        openAppSettings();
        return false;
      }
    }
  }

  Future<void> _savePdfToFile(Uint8List pdfBytes, BuildContext context) async {
    if (await requestStoragePermission()) {
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else {
        final appDocDirectory = await getApplicationDocumentsDirectory();
        downloadsDirectory = Directory(appDocDirectory.path);
      }

      if (await downloadsDirectory.exists()) {
        final file = File(
            '${downloadsDirectory.path}/melo_analytics_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(pdfBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Report saved to downloads',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.greenAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission to access storage is required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.background,
        titleSpacing: 0,
        title: const Text(
          'Report preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ),
      body: PdfPreview(
        build: _buildPdf,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        actionBarTheme:
            const PdfActionBarTheme(backgroundColor: AppColors.background),
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, buildPdf, format) async {
              final pdfBytes = await buildPdf(format);
              if (context.mounted) {
                await _savePdfToFile(pdfBytes, context);
              }
            },
          ),
          PdfPreviewAction(
            icon: const Icon(Icons.share),
            onPressed: (context, buildPdf, format) async {
              final pdfBytes = await buildPdf(format);
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename:
                    'melo_analytics_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
              );
            },
          ),
        ],
      ),
    );
  }
}
