import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tax_report_screen.dart';
import 'regime_comparison_screen.dart';
class TaxFilingScreen extends StatefulWidget {
  final List<dynamic> companies;
  const TaxFilingScreen({Key? key, required this.companies}) : super(key: key);

  @override
  _TaxFilingScreenState createState() => _TaxFilingScreenState();
}

class _TaxFilingScreenState extends State<TaxFilingScreen> {
  String? _selectedCompanyId;
  final _yearController = TextEditingController(text: '2024-2025');
  
  // Financial Inputs
  final _grossRevenueController = TextEditingController();
  final _operatingIncomeController = TextEditingController();
  final _stcgController = TextEditingController();
  final _ltcgController = TextEditingController();
  
  final _operatingExpensesController = TextEditingController();
  final _depreciationController = TextEditingController();
  
  final _section80cController = TextEditingController();
  final _section80dController = TextEditingController();
  
  final _tdsController = TextEditingController();
  final _advanceTaxController = TextEditingController();

  bool _isLoading = false;

  void _compareRegimes() async {
    setState(() => _isLoading = true);
    
    final financialData = {
      'income': {
        'grossRevenue': double.tryParse(_grossRevenueController.text) ?? 0.0,
        'operatingIncome': double.tryParse(_operatingIncomeController.text) ?? 0.0,
        'stcg': double.tryParse(_stcgController.text) ?? 0.0,
        'ltcg': double.tryParse(_ltcgController.text) ?? 0.0,
      },
      'expenses': {
        'operating': double.tryParse(_operatingExpensesController.text) ?? 0.0,
        'depreciation': double.tryParse(_depreciationController.text) ?? 0.0,
      },
      'deductions': {
        'claimed': [
          if ((double.tryParse(_section80cController.text) ?? 0) > 0)
            {'type': 'SECTION_80C', 'amount': double.parse(_section80cController.text)},
          if ((double.tryParse(_section80dController.text) ?? 0) > 0)
            {'type': 'SECTION_80D', 'amount': double.parse(_section80dController.text)},
        ]
      },
      'credits': {
        'tds': double.tryParse(_tdsController.text) ?? 0.0,
        'advanceTax': double.tryParse(_advanceTaxController.text) ?? 0.0,
      }
    };

    try {
      final comparisonResult = await ApiService.compareRegimes(
        _yearController.text, 
        financialData
      );

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => RegimeComparisonScreen(
        taxYear: _yearController.text,
        financialData: financialData,
        comparisonResult: comparisonResult,
        companyId: _selectedCompanyId,
      )));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateFinalReport(String policyId, Map<String, dynamic> financialData) async {
    setState(() => _isLoading = true);
    try {
      final report = await ApiService.generateTaxReport({
        'companyId': _selectedCompanyId, // Null if individual
        'taxYear': _yearController.text,
        'selectedPolicyId': policyId,
        'financialData': financialData,
      });

      if (!mounted) return;
      // We push replacement so they can't go back to the comparison step directly
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
      appBar: AppBar(title: const Text('File Comprehensive Tax Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCompanyId,
                hint: const Text('Filing as Individual (No Company)'),
                items: widget.companies.map((c) => DropdownMenuItem(value: c['_id'] as String, child: Text(c['name'] as String))).toList(),
                onChanged: (val) => setState(() => _selectedCompanyId = val),
              ),
              const SizedBox(height: 16),
              TextField(controller: _yearController, decoration: const InputDecoration(labelText: 'Tax Year (e.g. 2024-2025)')),
              
              const SizedBox(height: 24),
              const Text('1. Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _grossRevenueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gross Revenue')),
              TextField(controller: _stcgController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Short-Term Capital Gains (STCG)')),
              TextField(controller: _ltcgController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Long-Term Capital Gains (LTCG)')),
              
              const SizedBox(height: 24),
              const Text('2. Expenses (Business/Professional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _operatingExpensesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Operating Expenses')),
              TextField(controller: _depreciationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Depreciation')),

              const SizedBox(height: 24),
              const Text('3. Deductions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _section80cController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Section 80C Claims')),
              TextField(controller: _section80dController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Section 80D (Health Insurance)')),

              const SizedBox(height: 24),
              const Text('4. Taxes Paid / Credits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: _tdsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'TDS Deducted')),
              TextField(controller: _advanceTaxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Advance Tax Paid')),

              const SizedBox(height: 32),
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _compareRegimes, child: const Text('Compare Regimes & Validate'))
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
