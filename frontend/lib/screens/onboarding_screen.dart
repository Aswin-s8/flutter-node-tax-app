import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  String? _ownsBusiness;
  int _expectedCompaniesCount = 0;
  String? _primaryFilingCategory;
  String? _industry;
  bool _requiresAccountant = false;

  final _industryController = TextEditingController();
  final _countController = TextEditingController(text: "0");

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_industryController.text.isNotEmpty) {
        _industry = _industryController.text;
      }
      _expectedCompaniesCount = int.tryParse(_countController.text) ?? 0;

      await ApiService.updateOnboarding({
        'ownsBusiness': _ownsBusiness ?? 'Not_Sure_Yet',
        'expectedCompaniesCount': _expectedCompaniesCount,
        'primaryFilingCategory': _primaryFilingCategory ?? 'Individual',
        'industry': _industry ?? 'N/A',
        'requiresAccountant': _requiresAccountant
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeDashboard()));
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
      appBar: AppBar(title: const Text('Personalize Your Profile')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 4) {
                setState(() => _currentStep += 1);
              } else {
                _submit();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
            steps: [
              Step(
                title: const Text('Do you own a business?'),
                content: DropdownButtonFormField<String>(
                  value: _ownsBusiness,
                  items: ['Yes', 'No', 'Not_Sure_Yet'].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(),
                  onChanged: (val) => setState(() => _ownsBusiness = val),
                  decoration: const InputDecoration(border: OutlineInputBorder())
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('How many companies do you own?'),
                content: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Company Count', border: OutlineInputBorder()),
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Primary Filing Category'),
                content: DropdownButtonFormField<String>(
                  value: _primaryFilingCategory,
                  items: ['Individual', 'Sole Proprietor', 'LLC', 'S-Corp', 'C-Corp'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _primaryFilingCategory = val),
                  decoration: const InputDecoration(border: OutlineInputBorder())
                ),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('What Industry are you in?'),
                content: TextField(
                  controller: _industryController,
                  decoration: const InputDecoration(labelText: 'E.g., Tech, Retail, Service', border: OutlineInputBorder()),
                ),
                isActive: _currentStep >= 3,
              ),
              Step(
                title: const Text('Do you require an Accountant?'),
                content: SwitchListTile(
                  title: const Text('Yes, I need expert help'),
                  value: _requiresAccountant,
                  onChanged: (val) => setState(() => _requiresAccountant = val),
                ),
                isActive: _currentStep >= 4,
              ),
            ]
        ),
    );
  }
}
