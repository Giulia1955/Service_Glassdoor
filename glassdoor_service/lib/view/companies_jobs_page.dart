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

class CompaniesJobsPage extends StatefulWidget {
  const CompaniesJobsPage({super.key});

  @override
  State<CompaniesJobsPage> createState() => _CompaniesJobsPageState();
}

class _CompaniesJobsPageState extends State<CompaniesJobsPage> {
  final _companyIdController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _service = GlassodoorService();

  Future<Map<String, dynamic>>? _future;
  String? _message;
  String _jobFunction = 'ANY';
  String? _locationType;
  String? _sort;

  static const _jobFunctions = <String>[
    'ANY',
    'ADMINISTRATIVE',
    'ARTS_AND_DESIGN',
    'BUSINESS',
    'CONSULTING',
    'CUSTOMER_SERVICES_AND_SUPPORT',
    'EDUCATION',
    'ENGINEERING',
    'FINANCE_AND_ACCOUNTING',
    'HEALTHCARE',
    'HUMAN_RESOURCES',
    'INFORMATION_TECHNOLOGY',
    'LEGAL',
    'MARKETING',
    'MEDIA_AND_COMMUNICATIONS',
    'MILITARY_AND_PROTECTIVE_SERVICES',
    'OPERATIONS',
    'OTHER',
    'PRODUCT_AND_PROJECT_MANAGEMENT',
    'RESEARCH_AND_SCIENCE',
    'RETAIL_AND_FOOD_SERVICES',
    'SALES',
    'SKILLED_LABOR_AND_MANUFACTURING',
    'TRANSPORTATION',
  ];

  @override
  void dispose() {
    _companyIdController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _submit() {
    final companyId = _companyIdController.text.trim();
    if (companyId.isEmpty) {
      setState(() => _message = 'Digite o ID da empresa.');
      return;
    }

    final maxAgeText = _maxAgeController.text.trim();
    final maxAge = maxAgeText.isEmpty ? null : int.tryParse(maxAgeText);
    if (maxAgeText.isNotEmpty && maxAge == null) {
      setState(() => _message = 'A idade máxima deve ser um número.');
      return;
    }

    setState(() {
      _message = null;
      _future = _service.companyjobs(
        _jobFunction == 'ANY' ? null : _jobFunction,
        maxAge,
        _locationType,
        _sort,
        companyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vagas por Empresa')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _companyIdController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'ID da empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _jobFunction,
              decoration: const InputDecoration(
                labelText: 'Área / função',
                border: OutlineInputBorder(),
              ),
              items: _jobFunctions
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _jobFunction = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxAgeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Idade máxima em dias (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _locationType,
                    decoration: const InputDecoration(
                      labelText: 'Localização',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'CITY', child: Text('Cidade')),
                      DropdownMenuItem(value: 'STATE', child: Text('Estado')),
                      DropdownMenuItem(value: 'COUNTRY', child: Text('País')),
                    ],
                    onChanged: (value) => setState(() => _locationType = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sort,
                    decoration: const InputDecoration(
                      labelText: 'Ordenar',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'RELEVANCE',
                        child: Text('Relevância'),
                      ),
                      DropdownMenuItem(value: 'DATE', child: Text('Data')),
                    ],
                    onChanged: (value) => setState(() => _sort = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Buscar vagas'),
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
      return stateMessage('Digite um ID de empresa para pesquisar.');
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
        final data = asMap(root['data']);
        final jobs = asMapList(data['jobs']).isNotEmpty
            ? asMapList(data['jobs'])
            : asMapList(root['jobs']);
        if (jobs.isEmpty) {
          return stateMessage('Nenhuma vaga encontrada.');
        }

        return ListView(children: jobs.map(_buildJobCard).toList());
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return resultCard(displayValue(job['job_title'] ?? job['title']), {
      'Empresa': displayValue(job['company_name']),
      'Local': displayValue(job['location']),
      'Salário': displayValue(job['salary']),
      'Tipo': displayValue(job['job_type']),
    }, description: job['description']?.toString());
  }
}
