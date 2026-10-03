import 'package:flutter/material.dart';
import 'package:glassdoor_service/service/glassdoor_service.dart';
import 'package:glassdoor_service/view/widgets.dart';

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
    final erroEmpresa = Validador.empresaNomeOuId(companyId);
    if (erroEmpresa != null) {
      setState(() => _message = erroEmpresa);
      return;
    }

    final maxAgeText = _maxAgeController.text.trim();
    final maxAge = maxAgeText.isEmpty ? null : int.tryParse(maxAgeText);
    if (maxAgeText.isNotEmpty && maxAge == null) {
      setState(() => _message = 'A idade máxima deve ser um número.');
      return;
    }
    final erroIdade = Validador.maxAgeDias(maxAge);
    if (erroIdade != null) {
      setState(() => _message = erroIdade);
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
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Nome ou ID da empresa',
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
                        value: 'MOST_RELEVANT',
                        child: Text('Relevância'),
                      ),
                      DropdownMenuItem(
                        value: 'MOST_RECENT',
                        child: Text('Data'),
                      ),
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
      return stateMessage(
        'Digite o nome ou ID de uma empresa para pesquisar.',
        showPatrick: true,
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return stateMessage(errorText(snapshot.error!), error: true);
        }

        final root = asMap(snapshot.data);
        final data = asMap(root['data']);
        final jobs = asMapList(data['jobs']).isNotEmpty
            ? asMapList(data['jobs'])
            : asMapList(root['jobs']);
        if (jobs.isEmpty) {
          return stateMessage('Nenhuma vaga encontrada.', showPatrick: true);
        }

        return ListView(
          children: [
            const GifBanner(term: 'job search'),
            ...jobs.map(_buildJobCard),
          ],
        );
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return resultCard(
      displayValue(job['job_title'] ?? job['title']),
      {
        'Empresa': displayValue(job['company_name']),
        'Local': displayValue(job['location']),
        'Salário': displayValue(job['salary']),
        'Tipo': displayValue(job['job_type']),
      },
      description: job['description']?.toString(),
    );
  }
}
