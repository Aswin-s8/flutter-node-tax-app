import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'company_registration.dart';
import 'tax_filing_screen.dart';
import 'login_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  List<dynamic> _companies = [];
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final companies = await ApiService.getCompanies();
      final reports = await ApiService.getTaxReports();
      setState(() {
        _companies = companies;
        _reports = reports;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Companies', style: Theme.of(context).textTheme.titleLarge),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyRegistrationScreen())).then((_) => _loadData()),
                        child: const Text('Add Node'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_companies.isEmpty)
                    const Text("No companies registered yet. You can file as an individual.")
                  else
                    ..._companies.map((c) => ListTile(title: Text(c['name']), subtitle: Text(c['companyType'] ?? ''))),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax Reports', style: Theme.of(context).textTheme.titleLarge),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaxFilingScreen(companies: _companies))).then((_) => _loadData()),
                        child: const Text('File Report'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_reports.isEmpty)
                    const Text("No tax reports generated yet.")
                  else
                    ..._reports.map((r) => Card(
                          child: ListTile(
                            title: Text('Tax Year: ${r['taxYear']}'),
                            subtitle: Text('Status: ${r['filingStatus']} - Estimated Tax: \$${r['estimatedTaxOwed']}'),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
