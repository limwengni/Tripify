import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/ad_transaction_model.dart';

class ReceiptPage extends StatelessWidget {
  final AdsTransaction transaction;

  ReceiptPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Success Message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Transaction Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransactionDetailRow(
                      'Transaction ID:',
                      transaction.transactionId,
                    ),
                    SizedBox(height: 8),
                    _buildTransactionDetailRow(
                      'Top Up Amount:',
                      'RM${transaction.amount.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 8),
                    _buildTransactionDetailRow(
                      'Date and Time:',
                      DateFormat('dd MMM yyyy hh:mm:ss a')
                          .format(transaction.date.toLocal()),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Export Receipt Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pdf = pw.Document();
                      pdf.addPage(
                        pw.Page(build: (pw.Context context) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(16.0),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Transaction Receipt',
                                    style: pw.TextStyle(
                                        fontSize: 24,
                                        fontWeight: pw.FontWeight.bold)),
                                pw.SizedBox(height: 16),
                                pw.Text('Transaction ID: ${transaction.transactionId}',
                                    style: pw.TextStyle(fontSize: 18)),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                    'Top Up Amount: RM${transaction.amount.toStringAsFixed(2)}',
                                    style: pw.TextStyle(fontSize: 18)),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                    'Date and Time: ${DateFormat('dd MMM yyyy hh:mm:ss a').format(transaction.date.toLocal())}',
                                    style: pw.TextStyle(fontSize: 18)),
                              ],
                            ),
                          );
                        }),
                      );

                      final output = await getTemporaryDirectory();
                      final file = File("${output.path}/receipt.pdf");
                      await file.writeAsBytes(await pdf.save());

                      OpenFilex.open(file.path);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Receipt exported successfully!'),
                            backgroundColor: Color(0xFF9F76F9)),
                      );
                    },
                    icon: Icon(Icons.file_download, color: Colors.white),
                    label: Text('Export Receipt',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Return to Wallet Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.wallet, color: Colors.white),
                    label: Text('Return to Wallet',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9F76F9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
