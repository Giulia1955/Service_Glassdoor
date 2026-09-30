import 'package:flutter/material.dart';
import 'package:glassdoor_service/service/glassdoor_service.dart';

String displayValue(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return 'Não informado';
  return value.toString();
}

Map<String, dynamic> asMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Widget stateMessage(String message, {bool error = false}) {
  return Center(
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: error ? Colors.red : Colors.white),
    ),
  );
}

Widget resultCard(
  String title,
  Map<String, String> fields, {
  String? description,
}) {
  return Card(
    color: Colors.grey[900],
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          ...fields.entries.map(
            (entry) => Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (description != null && description.isNotEmpty)
            Text(description, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}

class CompanySearchPage extends StatefulWidget {
  const CompanySearchPage({super.key});

  @override
  State<CompanySearchPage> createState() => _CompanySearchPageState();
}

class _CompanySearchPageState extends State<CompanySearchPage> {
  final _controller = TextEditingController();
  final _service = GlassodoorService();
  Future<Map<String, dynamic>>? _future;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _message = 'Digite o nome de uma empresa.');
      return;
    }
    setState(() {
      _message = null;
      _future = _service.searchCompany(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Empresa')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Nome da empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Pesquisar'),
              ),
            ),
            if (_message != null) stateMessage(_message!, error: true),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_future == null) {
      return stateMessage('Digite o nome de uma empresa para pesquisar.');
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return stateMessage(snapshot.error.toString(), error: true);
        }

        final root = asMap(snapshot.data);
        final data = root['data'];
        final results = asMapList(data).isNotEmpty
            ? asMapList(data)
            : asMapList(asMap(data)['companies']);
        final companies = results.isNotEmpty
            ? results
            : asMapList(root['companies']);
        if (companies.isEmpty) {
          return stateMessage('Nenhuma empresa encontrada.');
        }

        return ListView(children: companies.map(_buildCompanyCard).toList());
      },
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return resultCard(
      displayValue(company['name'] ?? company['company_name']),
      {
        'Local': displayValue(
          company['location'] ?? company['city'] ?? company['state'],
        ),
        'Avaliação': displayValue(company['rating']),
        'ID': displayValue(company['company_id'] ?? company['id']),
      },
      description: company['description']?.toString(),
    );
  }
}
