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

class CompanyReviewPage extends StatefulWidget {
  const CompanyReviewPage({super.key});

  @override
  State<CompanyReviewPage> createState() => _CompanyReviewPageState();
}

class _CompanyReviewPageState extends State<CompanyReviewPage> {
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
    if (Validador.companyId(value) != null) {
      setState(() => _message = 'Digite um ID numérico de empresa.');
      return;
    }
    setState(() {
      _message = null;
      _future = _service.reviewCompany(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações da Empresa')),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'ID da empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Pesquisar avaliações'),
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
        final reviews = asMapList(data['reviews']).isNotEmpty
            ? asMapList(data['reviews'])
            : asMapList(root['reviews']);
        if (reviews.isEmpty) {
          return stateMessage('Nenhuma avaliação encontrada.');
        }

        return ListView(children: reviews.map(_buildReviewCard).toList());
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return resultCard(
      displayValue(review['headline'] ?? review['summary']),
      {
        'Cargo': displayValue(review['job_title']),
        'Data': displayValue(review['review_date']),
        'Avaliação': displayValue(review['rating']),
        'Recomendaria': displayValue(
          review['recommend_to_friend'] ?? review['recommendation'],
        ),
      },
      description: [review['pros'], review['cons'], review['summary']]
          .whereType<String>()
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n'),
    );
  }
}
