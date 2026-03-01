import 'package:flutter/material.dart';

class TaxReportScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const TaxReportScreen({Key? key, required this.reportData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Report Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Year: ${reportData['taxYear']}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Total Income'),
              trailing: Text('\$${reportData['totalIncome']}'),
            ),
            ListTile(
              title: const Text('Total Deductions'),
              trailing: Text('\$${reportData['totalDeductions']}'),
            ),
            const Divider(),
            ListTile(
              title: const Text('Estimated Tax Owed', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('\$${reportData['estimatedTaxOwed']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
