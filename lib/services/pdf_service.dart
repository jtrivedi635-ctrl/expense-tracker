import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/expense_model.dart';

class PdfService {
  static Future<void> generateAndOpenPdf(List<ExpenseModel> expenses) async {
    final pdf = pw.Document();

    // App theme colors
    final primaryColor = PdfColor.fromHex('#4ecdc4');
    final accentColor = PdfColor.fromHex('#ff6b6b'); // Expense color

    final double totalExpenses =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(primaryColor),
        footer: (context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            _buildExpenseTable(expenses, primaryColor),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            _buildTotal(totalExpenses, accentColor),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/expense_report.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  static pw.Widget _buildHeader(PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Expense Report',
              style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor),
            ),
            pw.Text(
              DateFormat.yMMMMd().format(DateTime.now()),
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 3, color: primaryColor),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildExpenseTable(List<ExpenseModel> expenses, PdfColor headerColor) {
    const tableHeaders = ['Date', 'Title', 'Category', 'Amount'];
    
    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: expenses.map((e) => [
        DateFormat('dd MMM, yyyy').format(e.date),
        e.title,
        e.category,
        e.amount.toStringAsFixed(2),
      ]).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: pw.BoxDecoration(
        color: headerColor,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  static pw.Widget _buildTotal(double total, PdfColor accentColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total Expenses',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            total.toStringAsFixed(2),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
