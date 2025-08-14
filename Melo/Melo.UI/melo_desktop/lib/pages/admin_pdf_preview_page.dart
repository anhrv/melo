import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/datetime_util.dart';
import 'package:melo_desktop/utils/toast_util.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class AdminPdfPreviewPage extends StatefulWidget {
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

  @override
  State<AdminPdfPreviewPage> createState() => _AdminPdfPreviewPageState();
}

class _AdminPdfPreviewPageState extends State<AdminPdfPreviewPage> {
  bool _isDownloading = false;
  bool _isOpening = false;

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final hasLikes = widget.data.any((item) => item.containsKey('likeCount'));

    final headers = ['Name', 'Views', if (hasLikes) 'Likes'];

    final rows = widget.data.map((item) {
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
              'Top ${widget.data.length} ${widget.ascending ? 'Least' : 'Most'} ${widget.sortBy == 'likeCount' ? 'Liked' : 'Viewed'} ${widget.entity[0].toUpperCase()}${widget.entity.substring(1)}s Report',
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

  Future<void> _savePdfToFile(Uint8List pdfBytes, BuildContext context) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName:
          'melo_analytics_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = File(result);
    await file.writeAsBytes(pdfBytes);

    if (context.mounted) {
      ToastUtil.showToast("Report saved successfully", false, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Report preview",
      ),
      body: PdfPreview(
        build: _buildPdf,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        actionBarTheme:
            const PdfActionBarTheme(backgroundColor: AppColors.background),
        actions: [
          PdfPreviewAction(
            icon: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading
                ? null
                : (context, buildPdf, format) async {
                    setState(() => _isDownloading = true);
                    try {
                      final pdfBytes = await buildPdf(format);
                      if (mounted) {
                        await _savePdfToFile(pdfBytes, context);
                      }
                    } finally {
                      if (mounted) setState(() => _isDownloading = false);
                    }
                  },
          ),
          PdfPreviewAction(
            icon: _isOpening
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  )
                : const Icon(Icons.language),
            onPressed: _isOpening
                ? null
                : (context, buildPdf, format) async {
                    setState(() => _isOpening = true);
                    try {
                      final pdfBytes = await buildPdf(format);
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename:
                            'melo_analytics_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
                      );
                    } finally {
                      if (mounted) setState(() => _isOpening = false);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
