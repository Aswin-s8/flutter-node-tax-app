import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class TaxReportScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const TaxReportScreen({Key? key, required this.reportData}) : super(key: key);

  Future<void> _launchPDF(BuildContext context) async {
    final pdfUrl = reportData['pdfUrl'];
    final reportId = reportData['reportId']; // the mongo ID
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No PDF available.')));
      return;
    }
    
    final url = Uri.parse(ApiService.getDownloadUrl(reportId));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch PDF.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = reportData['summary'];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Report Summary')),
      body: summary == null ? const Center(child: Text("Incomplete data generated.")) : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Tax Year: ${reportData['summary']['taxYear'] ?? "2024-2025"}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Executive Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ListTile(title: const Text('Gross Revenue'), trailing: Text('\$${summary['grossRevenue']?.toStringAsFixed(2)}')),
                  ListTile(title: const Text('Total Expenses'), trailing: Text('\$${summary['totalExpenses']?.toStringAsFixed(2)}')),
                  ListTile(title: const Text('Total Deductions'), trailing: Text('\$${summary['totalDeductions']?.toStringAsFixed(2)}')),
                  ListTile(title: const Text('Taxable Income'), trailing: Text('\$${summary['taxableIncome']?.toStringAsFixed(2)}')),
                  const Divider(),
                  ListTile(title: const Text('Final Tax Liability (Base + Surcharge + Cess)'), trailing: Text('\$${summary['totalTax']?.toStringAsFixed(2)}')),
                  ListTile(title: const Text('Credits (TDS/Advance)'), trailing: Text('\$${((summary['totalTax'] ?? 0) - (summary['netPayable'] ?? 0)).toStringAsFixed(2)}')),
                  ListTile(
                    title: const Text('Net Payable', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('\$${summary['netPayable']?.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  ListTile(title: const Text('Effective Tax Rate'), trailing: Text('${summary['effectiveRate']?.toStringAsFixed(2)}%')),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download Full PDF Report'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () => _launchPDF(context),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}
