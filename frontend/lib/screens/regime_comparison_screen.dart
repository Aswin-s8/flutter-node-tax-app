import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tax_report_screen.dart';

class RegimeComparisonScreen extends StatefulWidget {
  final String taxYear;
  final Map<String, dynamic> financialData;
  final Map<String, dynamic> comparisonResult;
  final String? companyId;

  const RegimeComparisonScreen({
    Key? key,
    required this.taxYear,
    required this.financialData,
    required this.comparisonResult,
    this.companyId,
  }) : super(key: key);

  @override
  _RegimeComparisonScreenState createState() => _RegimeComparisonScreenState();
}

class _RegimeComparisonScreenState extends State<RegimeComparisonScreen> {
  bool _isLoading = false;

  Future<void> _generateFinalReport(String policyId) async {
    setState(() => _isLoading = true);
    try {
      final report = await ApiService.generateTaxReport({
        'companyId': widget.companyId,
        'taxYear': widget.taxYear,
        'selectedPolicyId': policyId,
        'financialData': widget.financialData,
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TaxReportScreen(reportData: report)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.comparisonResult['results'] as List<dynamic>;
    final recommendedPolicyId = widget.comparisonResult['recommendedPolicyId'];
    final savings = widget.comparisonResult['savingsAgainstMax'];

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Tax Regimes')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Text('Optimal Regime Found!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 8),
                    Text('You save \$${savings.toStringAsFixed(2)} by choosing the recommended regime.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Available Regimes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...results.map((regime) {
                final isRecommended = regime['policyId'] == recommendedPolicyId;
                return Card(
                  elevation: isRecommended ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isRecommended ? Colors.green : Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(regime['regimeName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (isRecommended)
                              const Chip(label: Text('Recommended', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                          ],
                        ),
                        const Divider(),
                        ListTile(title: const Text('Gross Revenue'), trailing: Text('\$${regime['grossRevenue'].toStringAsFixed(2)}')),
                        ListTile(title: const Text('Total Deductions Allowed'), trailing: Text('\$${regime['totalDeductions'].toStringAsFixed(2)}')),
                        ListTile(title: const Text('Taxable Income'), trailing: Text('\$${regime['taxableIncome'].toStringAsFixed(2)}')),
                        const Divider(),
                        ListTile(
                          title: const Text('Total Tax Liability', style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('\$${regime['totalTax'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ListTile(
                          title: const Text('Effective Tax Rate'),
                          trailing: Text('${regime['effectiveRate'].toStringAsFixed(2)}%'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _generateFinalReport(regime['policyId']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRecommended ? Colors.green : Colors.blue,
                            ),
                            child: const Text('Select & Generate Final Report'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
    );
  }
}
