import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tax_report_screen.dart';

class TaxFilingScreen extends StatefulWidget {
  final List<dynamic> companies;
  const TaxFilingScreen({Key? key, required this.companies}) : super(key: key);

  @override
  _TaxFilingScreenState createState() => _TaxFilingScreenState();
}

class _TaxFilingScreenState extends State<TaxFilingScreen> {
  String? _selectedCompanyId;
  final _yearController = TextEditingController(text: DateTime.now().year.toString());
  final _incomeController = TextEditingController();
  final _deductionsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await ApiService.generateTaxReport({
        'companyId': _selectedCompanyId, // Null if individual
        'taxYear': int.tryParse(_yearController.text) ?? DateTime.now().year,
        'income': double.tryParse(_incomeController.text) ?? 0.0,
        'deductions': double.tryParse(_deductionsController.text) ?? 0.0,
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
    return Scaffold(
      appBar: AppBar(title: const Text('File Tax Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCompanyId,
              hint: const Text('Filing as Individual (No Company)'),
              items: widget.companies.map((c) => DropdownMenuItem(value: c['_id'] as String, child: Text(c['name'] as String))).toList(),
              onChanged: (val) => setState(() => _selectedCompanyId = val),
            ),
            const SizedBox(height: 16),
            TextField(controller: _yearController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tax Year')),
            const SizedBox(height: 16),
            TextField(controller: _incomeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Income')),
            const SizedBox(height: 16),
            TextField(controller: _deductionsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Deductions (Expenses)')),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _generateReport, child: const Text('Generate Report')),
          ],
        ),
      ),
    );
  }
}
