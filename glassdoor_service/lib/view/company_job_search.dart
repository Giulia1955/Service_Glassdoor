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

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  final _termController = TextEditingController();
  final _locationController = TextEditingController();
  final _service = GlassodoorService();
  Future<Map<String, dynamic>>? _future;
  String? _message;
  String? _locationType;
  String? _minRating;
  bool _remoteOnly = false;
  bool _easyApplyOnly = false;

  @override
  void dispose() {
    _termController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    final term = _termController.text.trim();
    final location = _locationController.text.trim();
    if (term.isEmpty || location.isEmpty) {
      setState(() => _message = 'Informe o cargo e a localização.');
      return;
    }
    setState(() {
      _message = null;
      _future = _service.jobSearch(
        term,
        _remoteOnly,
        _minRating,
        _easyApplyOnly,
        _locationType,
        location,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Vagas')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _termController,
              decoration: const InputDecoration(
                labelText: 'Cargo ou termo da vaga',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Localização',
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
                      labelText: 'Tipo de local',
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
                    initialValue: _minRating,
                    decoration: const InputDecoration(
                      labelText: 'Avaliação mínima',
                      border: OutlineInputBorder(),
                    ),
                    items: ['1', '2', '3', '4', '5']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _minRating = value),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Somente remoto'),
              value: _remoteOnly,
              onChanged: (value) => setState(() => _remoteOnly = value),
            ),
            SwitchListTile(
              title: const Text('Somente candidatura fácil'),
              value: _easyApplyOnly,
              onChanged: (value) => setState(() => _easyApplyOnly = value),
            ),
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
      return stateMessage('Informe os filtros para pesquisar vagas.');
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
    return resultCard(
      displayValue(job['job_title'] ?? job['title']),
      {
        'Empresa': displayValue(job['company_name']),
        'Local': displayValue(job['location']),
        'Salário': displayValue(job['salary']),
        'Tipo': displayValue(job['job_type']),
      },
      description:
          job['description']?.toString() ?? job['job_description']?.toString(),
    );
  }
}
