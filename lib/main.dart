import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MasterAdminApp());
}

class MasterAdminApp extends StatelessWidget {
  const MasterAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Tech Master Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MasterLoginScreen(),
    );
  }
}

class MasterLoginScreen extends StatefulWidget {
  const MasterLoginScreen({super.key});

  @override
  State<MasterLoginScreen> createState() => _MasterLoginScreenState();
}

class _MasterLoginScreenState extends State<MasterLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  void _login() {
    if (_passwordController.text == 'MASTER2024') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MasterDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid master password'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text('D-Tech Master Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Complete Control Dashboard', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                ),
                child: const Text('LOGIN'),
              ),
              const SizedBox(height: 16),
              const Text('Enter: MASTER2024', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class MasterDashboard extends StatefulWidget {
  const MasterDashboard({super.key});

  @override
  State<MasterDashboard> createState() => _MasterDashboardState();
}

class _MasterDashboardState extends State<MasterDashboard> {
  int _selectedIndex = 0;
  String? _selectedCompanyId;
  
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _merchandisers = [];
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _auditLogs = [];
  
  bool _isLoading = true;
  bool _showPasswords = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    final companiesJson = prefs.getString('master_companies');
    if (companiesJson != null && companiesJson.isNotEmpty) {
      _companies = List<Map<String, dynamic>>.from(jsonDecode(companiesJson));
    }
    
    final merchandisersJson = prefs.getString('master_merchandisers');
    if (merchandisersJson != null && merchandisersJson.isNotEmpty) {
      _merchandisers = List<Map<String, dynamic>>.from(jsonDecode(merchandisersJson));
    }
    
    final storesJson = prefs.getString('master_stores');
    if (storesJson != null && storesJson.isNotEmpty) {
      _stores = List<Map<String, dynamic>>.from(jsonDecode(storesJson));
    }
    
    final auditLogsJson = prefs.getString('master_audit_logs');
    if (auditLogsJson != null && auditLogsJson.isNotEmpty) {
      _auditLogs = List<Map<String, dynamic>>.from(jsonDecode(auditLogsJson));
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('master_companies', jsonEncode(_companies));
    await prefs.setString('master_merchandisers', jsonEncode(_merchandisers));
    await prefs.setString('master_stores', jsonEncode(_stores));
    await prefs.setString('master_audit_logs', jsonEncode(_auditLogs));
  }

  void _addAuditLog(String action, String details) {
    _auditLogs.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'user': 'Master Admin',
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _saveAllData();
  }

  void _addCompany() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Company'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Company Name'), autofocus: true),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Company Code')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && codeCtrl.text.isNotEmpty) {
                setState(() {
                  _companies.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameCtrl.text,
                    'code': codeCtrl.text.toUpperCase(),
                    'createdAt': DateTime.now().toIso8601String(),
                  });
                });
                _saveAllData();
                _addAuditLog('Add Company', 'Added company: ${nameCtrl.text}');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Company added!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addMerchandiser() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'MERCH2024');
    String? companyId = _selectedCompanyId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Merchandiser'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: companyId,
                    decoration: const InputDecoration(labelText: 'Company'),
                    items: _companies.map((c) => DropdownMenuItem<String>(
                      value: c['id'].toString(),
                      child: Text(c['name']),
                    )).toList(),
                    onChanged: (value) => setStateDialog(() => companyId = value),
                  ),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                  TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Employee Code')),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && codeCtrl.text.isNotEmpty && companyId != null) {
                    setState(() {
                      _merchandisers.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'name': nameCtrl.text,
                        'email': emailCtrl.text,
                        'phone': phoneCtrl.text,
                        'companyId': companyId,
                        'employeeCode': codeCtrl.text.toUpperCase(),
                        'password': passCtrl.text,
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                    });
                    _saveAllData();
                    _addAuditLog('Add Merchandiser', 'Added: ${nameCtrl.text}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Merchandiser added!'), backgroundColor: Colors.green),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addStore() {
    final nameCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '20');
    String? companyId = _selectedCompanyId;
    String? assignedTo;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Store'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: companyId,
                    decoration: const InputDecoration(labelText: 'Company'),
                    items: _companies.map((c) => DropdownMenuItem<String>(
                      value: c['id'].toString(),
                      child: Text(c['name']),
                    )).toList(),
                    onChanged: (value) => setStateDialog(() => companyId = value),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: assignedTo,
                    decoration: const InputDecoration(labelText: 'Assign to Merchandiser'),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Unassigned')),
                      ..._merchandisers.where((m) => m['companyId'] == companyId).map((m) => DropdownMenuItem<String>(
                        value: m['id'].toString(),
                        child: Text(m['name']),
                      )),
                    ],
                    onChanged: (value) => setStateDialog(() => assignedTo = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Store Name')),
                  TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
                  TextField(controller: lngCtrl, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
                  TextField(controller: radiusCtrl, decoration: const InputDecoration(labelText: 'Radius (meters)'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && companyId != null) {
                    setState(() {
                      _stores.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'name': nameCtrl.text,
                        'latitude': double.parse(latCtrl.text),
                        'longitude': double.parse(lngCtrl.text),
                        'radiusMeters': int.parse(radiusCtrl.text),
                        'companyId': companyId,
                        'assignedTo': assignedTo,
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                    });
                    _saveAllData();
                    _addAuditLog('Add Store', 'Added store: ${nameCtrl.text}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Store added!'), backgroundColor: Colors.green),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQRForMerchandiser(String merchandiserId, String merchandiserName) {
    final storesForMerch = _stores.where((s) => s['assignedTo'] == merchandiserId).toList();
    
    if (storesForMerch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stores assigned'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final qrData = jsonEncode({
      'merchandiser_id': merchandiserId,
      'merchandiser_name': merchandiserName,
      'stores': storesForMerch,
    });
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(merchandiserName),
              const SizedBox(height: 8),
              QrImageView(data: qrData, version: QrVersions.auto, size: 200),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: qrData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied!'), backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportCompanyData() {
    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a company first'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final company = _companies.firstWhere((c) => c['id'] == _selectedCompanyId);
    final companyMerchandisers = _merchandisers.where((m) => m['companyId'] == _selectedCompanyId).toList();
    final companyStores = _stores.where((s) => s['companyId'] == _selectedCompanyId).toList();
    
    final exportData = {
      'company': company,
      'merchandisers': companyMerchandisers,
      'stores': companyStores,
    };
    
    Clipboard.setData(ClipboardData(text: jsonEncode(exportData)));
    _addAuditLog('Export Data', 'Exported company: ${company['name']}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMerchandisers = _selectedCompanyId == null 
        ? _merchandisers 
        : _merchandisers.where((m) => m['companyId'] == _selectedCompanyId).toList();
    
    final filteredStores = _selectedCompanyId == null
        ? _stores
        : _stores.where((s) => s['companyId'] == _selectedCompanyId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Master Admin'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCompanyId,
                  hint: const Text('All Companies', style: TextStyle(color: Colors.white70)),
                  dropdownColor: Colors.red.shade700,
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All Companies', style: TextStyle(color: Colors.white))),
                    ..._companies.map((c) => DropdownMenuItem<String>(
                      value: c['id'].toString(),
                      child: Text(c['name'], style: const TextStyle(color: Colors.white)),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedCompanyId = value),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_showPasswords ? Icons.visibility_off : Icons.visibility, color: Colors.white),
              onPressed: () => setState(() => _showPasswords = !_showPasswords),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                  Text('Master Control', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () => setState(() => _selectedIndex = 0)),
            ListTile(leading: const Icon(Icons.business), title: const Text('Companies'), onTap: () => setState(() => _selectedIndex = 1)),
            ListTile(leading: const Icon(Icons.people), title: const Text('Merchandisers'), onTap: () => setState(() => _selectedIndex = 2)),
            ListTile(leading: const Icon(Icons.store), title: const Text('Stores'), onTap: () => setState(() => _selectedIndex = 3)),
            ListTile(leading: const Icon(Icons.history), title: const Text('Audit Logs'), onTap: () => setState(() => _selectedIndex = 4)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MasterLoginScreen())),
            ),
          ],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildCurrentScreen(_selectedIndex, filteredMerchandisers, filteredStores),
    );
  }

  Widget _buildCurrentScreen(int index, List<Map<String, dynamic>> merchandisers, List<Map<String, dynamic>> stores) {
    switch (index) {
      case 0: return _buildDashboard();
      case 1: return _buildCompaniesScreen();
      case 2: return _buildMerchandisersScreen(merchandisers);
      case 3: return _buildStoresScreen(stores);
      case 4: return _buildAuditLogsScreen();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Companies', _companies.length, Icons.business, Colors.blue)),
              Expanded(child: _buildStatCard('Merchandisers', _merchandisers.length, Icons.people, Colors.green)),
              Expanded(child: _buildStatCard('Stores', _stores.length, Icons.store, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Quick Actions'),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(onPressed: _addCompany, icon: const Icon(Icons.business), label: const Text('Add Company')),
                      ElevatedButton.icon(onPressed: _addMerchandiser, icon: const Icon(Icons.person_add), label: const Text('Add Merchandiser')),
                      ElevatedButton.icon(onPressed: _addStore, icon: const Icon(Icons.add_business), label: const Text('Add Store')),
                      ElevatedButton.icon(onPressed: _exportCompanyData, icon: const Icon(Icons.upload), label: const Text('Export Data')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Companies'),
              const Spacer(),
              ElevatedButton.icon(onPressed: _addCompany, icon: const Icon(Icons.add), label: const Text('Add Company')),
            ],
          ),
        ),
        Expanded(
          child: _companies.isEmpty
              ? const Center(child: Text('No companies'))
              : ListView.builder(
                  itemCount: _companies.length,
                  itemBuilder: (context, index) {
                    final c = _companies[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.business, color: Colors.blue),
                        title: Text(c['name']),
                        subtitle: Text('Code: ${c['code']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _companies.removeWhere((x) => x['id'] == c['id']);
                              _merchandisers.removeWhere((x) => x['companyId'] == c['id']);
                              _stores.removeWhere((x) => x['companyId'] == c['id']);
                            });
                            _saveAllData();
                            _addAuditLog('Delete Company', 'Deleted: ${c['name']}');
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMerchandisersScreen(List<Map<String, dynamic>> merchandisers) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Merchandisers'),
              const Spacer(),
              ElevatedButton.icon(onPressed: _addMerchandiser, icon: const Icon(Icons.add), label: const Text('Add Merchandiser')),
            ],
          ),
        ),
        Expanded(
          child: merchandisers.isEmpty
              ? const Center(child: Text('No merchandisers'))
              : ListView.builder(
                  itemCount: merchandisers.length,
                  itemBuilder: (context, index) {
                    final m = merchandisers[index];
                    final company = _companies.firstWhere((c) => c['id'] == m['companyId'], orElse: () => {'name': 'Unknown'});
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.green),
                        title: Text(m['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${company['name']} | ${m['employeeCode']}'),
                            if (_showPasswords) Text('Password: ${m['password']}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.qr_code, color: Colors.blue),
                              onPressed: () => _showQRForMerchandiser(m['id'], m['name']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _merchandisers.removeWhere((x) => x['id'] == m['id']));
                                _saveAllData();
                                _addAuditLog('Delete Merchandiser', 'Deleted: ${m['name']}');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStoresScreen(List<Map<String, dynamic>> stores) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Stores'),
              const Spacer(),
              ElevatedButton.icon(onPressed: _addStore, icon: const Icon(Icons.add), label: const Text('Add Store')),
            ],
          ),
        ),
        Expanded(
          child: stores.isEmpty
              ? const Center(child: Text('No stores'))
              : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final s = stores[index];
                    final company = _companies.firstWhere((c) => c['id'] == s['companyId'], orElse: () => {'name': 'Unknown'});
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.store, color: Colors.orange),
                        title: Text(s['name']),
                        subtitle: Text('${company['name']} | ${s['latitude']}, ${s['longitude']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _stores.removeWhere((x) => x['id'] == s['id']));
                            _saveAllData();
                            _addAuditLog('Delete Store', 'Deleted: ${s['name']}');
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAuditLogsScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Audit Logs'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  setState(() => _auditLogs.clear());
                  _saveAllData();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _auditLogs.isEmpty
              ? const Center(child: Text('No logs'))
              : ListView.builder(
                  itemCount: _auditLogs.length,
                  itemBuilder: (context, index) {
                    final log = _auditLogs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(log['action']),
                        subtitle: Text(log['details']),
                        trailing: Text(_formatDate(log['timestamp'])),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            Text(count.toString(), style: const TextStyle(fontSize: 28)),
            Text(title),
          ],
        ),
      ),
    );
  }
}
