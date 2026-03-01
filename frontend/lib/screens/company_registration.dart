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
  String? _companyType;
  bool _isLoading = false;

  Future<void> _registerCompany() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await ApiService.registerCompany({
        'name': _nameController.text,
        'taxId': _taxIdController.text,
        'industry': _industryController.text,
        'companyType': _companyType ?? 'LLC'
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
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Company Name')),
            const SizedBox(height: 16),
            TextField(controller: _taxIdController, decoration: const InputDecoration(labelText: 'Tax ID / EIN')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _companyType,
              hint: const Text('Company Type'),
              items: ['LLC', 'S-Corp', 'C-Corp', 'Sole Proprietorship', 'Partnership'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _companyType = val),
            ),
            const SizedBox(height: 16),
            TextField(controller: _industryController, decoration: const InputDecoration(labelText: 'Industry')),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _registerCompany, child: const Text('Save Company')),
          ],
        ),
      ),
    );
  }
}
