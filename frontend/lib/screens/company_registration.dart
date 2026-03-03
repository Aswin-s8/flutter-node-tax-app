import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({Key? key}) : super(key: key);

  @override
  _CompanyRegistrationScreenState createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _industryController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _exportPercentageController = TextEditingController();
  
  String? _companyType;
  bool _msmeStatus = false;
  bool _startupRecognition = false;
  bool _isLoading = false;

  Future<void> _registerCompany() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await ApiService.registerCompany({
        'name': _nameController.text,
        'taxId': _taxIdController.text,
        'industry': _industryController.text,
        'companyType': _companyType ?? 'LLC',
        'turnover': double.tryParse(_turnoverController.text) ?? 0.0,
        'employeeCount': int.tryParse(_employeeCountController.text) ?? 0,
        'exportPercentage': double.tryParse(_exportPercentageController.text) ?? 0.0,
        'msmeStatus': _msmeStatus,
        'startupRecognition': _startupRecognition,
      });
      if (!mounted) return;
      Navigator.pop(context); // Go back to dashboard
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
      appBar: AppBar(title: const Text('Register Company')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Company Name')),
              const SizedBox(height: 16),
              TextField(controller: _taxIdController, decoration: const InputDecoration(labelText: 'Registration ID / EIN')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _companyType,
                hint: const Text('Company Type'),
                items: ['LLC', 'S-Corp', 'C-Corp', 'Sole Proprietorship', 'Partnership', 'Corporate MSME'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _companyType = val),
              ),
              const SizedBox(height: 16),
              TextField(controller: _industryController, decoration: const InputDecoration(labelText: 'Industry')),
              const SizedBox(height: 16),
              TextField(controller: _turnoverController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Annual Turnover (\$)')),
              const SizedBox(height: 16),
              TextField(controller: _employeeCountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Employees')),
              const SizedBox(height: 16),
              TextField(controller: _exportPercentageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Export Percentage (%)')),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Registered MSME"),
                value: _msmeStatus,
                onChanged: (val) => setState(() => _msmeStatus = val ?? false),
              ),
              CheckboxListTile(
                title: const Text("Recognized Startup"),
                value: _startupRecognition,
                onChanged: (val) => setState(() => _startupRecognition = val ?? false),
              ),
              const SizedBox(height: 32),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _registerCompany, child: const Text('Save Company')),
            ],
          ),
        ),
      ),
    );
  }
}
